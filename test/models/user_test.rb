require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires name and email" do
    user = User.new(shop: shops(:tea), password: "credential123")

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:email], "can't be blank"
  end

  test "normalizes and enforces unique email per shop" do
    shop = shops(:tea)
    user = User.new(shop:, name: " Another Staff ", email: " STAFF+manager@TEA.MOMGO.TEST ", password: "credential123")

    assert user.valid?
    assert_equal "Another Staff", user.name
    assert_equal "staff+manager@tea.momgo.test", user.email

    duplicate = User.new(shop:, name: "Duplicate", email: "staff@tea.momgo.test")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "scope respects Current.shop" do
    Current.shop = shops(:tea)
    assert_equal User.where(shop: shops(:tea)).ids.sort, User.all.ids.sort

    Current.shop = shops(:coffee)
    assert_equal User.where(shop: shops(:coffee)).ids.sort, User.all.ids.sort
  end

  test "requires password on create" do
    user = User.new(shop: shops(:tea), name: "Test", email: "test@tea.momgo.test")

    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "authenticates against password digest" do
    user = users(:tea_staff)

    assert user.authenticate("tea-credential")
    assert_not user.authenticate("wrong-credential")
  end

  test "lock helpers toggle state" do
    user = users(:tea_staff)

    refute user.locked?
    user.increment_failed_attempts!(threshold: 1)

    assert user.locked?

    user.unlock_account!
    refute user.locked?
    assert_equal 0, user.failed_attempts
  end

end
