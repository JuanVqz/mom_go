require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires name and slug" do
    product = Product.new(shop: shops(:tea))

    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
    assert_includes product.errors[:slug], "can't be blank"
  end

  test "validates slug uniqueness per shop" do
    product = Product.new(shop: shops(:tea), name: "Dup", slug: "classic-milk-tea")

    assert_not product.valid?
    assert_includes product.errors[:slug], "has already been taken"
  end

  test "base_price_cents must be non-negative" do
    product = Product.new(shop: shops(:tea), name: "Invalid", slug: "invalid", base_price_cents: -1)

    assert_not product.valid?
    assert_includes product.errors[:base_price_cents], "must be greater than or equal to 0"
  end

  test "ordered and available scopes" do
    products(:matcha_cloud).update!(available: false)
    Current.shop = shops(:tea)

    assert_equal [products(:classic_milk_tea).id, products(:matcha_cloud).id], Product.ordered.ids
    assert_equal [products(:classic_milk_tea).id], Product.available.ids
  end

  test "associations expose categories, sizes, and components" do
    product = products(:classic_milk_tea)

    assert_equal [categories(:tea_milk_teas).id], product.categories.ids
    assert_equal [product_categories(:classic_milk_tea_milk_teas).id], product.product_categories.ids
    assert_equal [sizes(:tea_regular).id, sizes(:tea_large).id].sort, product.sizes.ids.sort
    assert_equal [product_sizes(:classic_regular).id, product_sizes(:classic_large).id].sort, product.product_sizes.ids.sort
    assert_equal [
      components(:tea_assam_black_tea_base).id,
      components(:tea_house_milk_blend).id,
      components(:tea_tapioca).id,
      components(:tea_grass_jelly).id
    ].sort, product.components.ids.sort
    assert_equal [
      product_components(:classic_black_tea_base).id,
      product_components(:classic_house_milk_blend).id,
      product_components(:classic_tapioca).id,
      product_components(:classic_grass_jelly).id
    ].sort, product.product_components.ids.sort
  end
end
