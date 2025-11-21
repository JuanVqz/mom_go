require "test_helper"

class ProductComponentTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires price to be non-negative" do
    record = ProductComponent.new(
      shop: shops(:tea),
      product: products(:classic_milk_tea),
      component: components(:tea_tapioca),
      price_cents: -5
    )

    assert_not record.valid?
    assert_includes record.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "requires unique product/component per shop" do
    duplicate = ProductComponent.new(
      shop: shops(:tea),
      product: products(:classic_milk_tea),
      component: components(:tea_tapioca),
      price_cents: 0
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:product_id], "has already been taken"
  end

  test "defines default_portion enum" do
    record = ProductComponent.new(
      shop: shops(:tea),
      product: products(:matcha_cloud),
      component: components(:tea_grass_jelly)
    )

    assert record.default_portion_none?
    record.default_portion = :full
    assert record.default_portion_full?
  end
end
