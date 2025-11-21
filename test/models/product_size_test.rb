require "test_helper"

class ProductSizeTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires price to be non-negative" do
    size = ProductSize.new(
      shop: shops(:tea),
      product: products(:classic_milk_tea),
      size: sizes(:tea_regular),
      price_cents: -10
    )

    assert_not size.valid?
    assert_includes size.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "requires unique product/size per shop" do
    duplicate = ProductSize.new(
      shop: shops(:tea),
      product: products(:classic_milk_tea),
      size: sizes(:tea_regular),
      price_cents: 0
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:product_id], "has already been taken"
  end
end
