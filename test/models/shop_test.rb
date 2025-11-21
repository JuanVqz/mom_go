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

  test "exposes catalog associations" do
    shop = shops(:tea)

    assert_equal [categories(:tea_milk_teas).id, categories(:tea_signature_drinks).id].sort, shop.categories.ids.sort
    assert_equal [products(:classic_milk_tea).id, products(:matcha_cloud).id].sort, shop.products.ids.sort
    assert_equal [sizes(:tea_regular).id, sizes(:tea_large).id].sort, shop.sizes.ids.sort
    assert_equal [components(:tea_tapioca).id, components(:tea_grass_jelly).id, components(:tea_cheese_foam).id].sort, shop.components.ids.sort
  end
end
