require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  TestUser = Data.define(:id, :name)

  def teardown
    Current.reset
  end

  test "can set and get shop attribute" do
    shop = shops(:tea)
    Current.shop = shop

    assert_equal shop, Current.shop
  end

  test "can set and get user attribute" do
    user = TestUser.new(id: 1, name: "Test User")
    Current.user = user

    assert_equal user, Current.user
  end

  test "can set and get both shop and user attributes" do
    shop = shops(:tea)
    user = TestUser.new(id: 1, name: "Test User")

    Current.shop = shop
    Current.user = user

    assert_equal shop, Current.shop
    assert_equal user, Current.user
  end

  test "attributes are nil by default" do
    assert_nil Current.shop
    assert_nil Current.user
  end

  test "reset clears all attributes" do
    shop = shops(:tea)
    user = TestUser.new(id: 1, name: "Test User")

    Current.shop = shop
    Current.user = user

    assert_not_nil Current.shop
    assert_not_nil Current.user

    Current.reset

    assert_nil Current.shop
    assert_nil Current.user
  end
end
