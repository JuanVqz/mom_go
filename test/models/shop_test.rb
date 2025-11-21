require "test_helper"

class ShopTest < ActiveSupport::TestCase
  test "requires name and subdomain" do
    shop = Shop.new

    assert_not shop.valid?
    assert_includes shop.errors[:name], "can't be blank"
    assert_includes shop.errors[:subdomain], "can't be blank"
  end

  test "normalizes subdomain and enforces uniqueness" do
    shop = Shop.new(name: "Another", subdomain: " Tea ")
    assert_equal "tea", shop.subdomain
  end
end
