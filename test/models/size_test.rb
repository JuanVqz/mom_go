require "test_helper"

class SizeTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires name and slug" do
    size = Size.new(shop: shops(:tea))

    assert_not size.valid?
    assert_includes size.errors[:name], "can't be blank"
    assert_includes size.errors[:slug], "can't be blank"
  end

  test "validates slug uniqueness per shop" do
    size = Size.new(shop: shops(:tea), name: "Dup", slug: "regular")

    assert_not size.valid?
    assert_includes size.errors[:slug], "has already been taken"
  end

  test "price_cents must be non-negative" do
    size = Size.new(shop: shops(:tea), name: "Mini", slug: "mini", price_cents: -5)

    assert_not size.valid?
    assert_includes size.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "ordered and available scopes" do
    sizes(:tea_large).update!(available: false)
    Current.shop = shops(:tea)

    assert_equal [sizes(:tea_regular).id, sizes(:tea_large).id], Size.ordered.ids
    assert_equal [sizes(:tea_regular).id], Size.available.ids
  end

  test "has many product_sizes and products" do
    size = sizes(:tea_regular)

    assert_equal [product_sizes(:classic_regular).id, product_sizes(:matcha_regular).id].sort, size.product_sizes.ids.sort
    assert_equal [products(:classic_milk_tea).id, products(:matcha_cloud).id].sort, size.products.ids.sort
  end
end
