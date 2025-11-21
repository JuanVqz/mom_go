require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires name and email" do
    user = User.new(shop: shops(:tea))

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:email], "can't be blank"
  end

  test "normalizes and enforces unique email per shop" do
    shop = shops(:tea)
    user = User.new(shop:, name: " Another Staff ", email: " STAFF+manager@TEA.MOMGO.TEST ")

    assert user.valid?
    assert_equal "Another Staff", user.name
    assert_equal "staff+manager@tea.momgo.test", user.email

    duplicate = User.new(shop:, name: "Duplicate", email: "staff@tea.momgo.test")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "scope respects Current.shop" do
    Current.shop = shops(:tea)
    assert_equal [users(:tea_staff).id], User.all.ids

    Current.shop = shops(:coffee)
    assert_equal [users(:coffee_staff).id], User.all.ids
  end
end
