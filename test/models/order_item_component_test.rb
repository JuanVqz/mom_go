require "test_helper"

class OrderItemComponentTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires component name when no snapshot" do
    record = OrderItemComponent.new(order_item: order_items(:tea_classic_regular), price_cents: 10)

    assert_not record.valid?
    assert_includes record.errors[:component_name], "can't be blank"
  end

  test "price cents must be non-negative" do
    record = OrderItemComponent.new(
      order_item: order_items(:tea_classic_regular),
      component: components(:tea_tapioca),
      component_name: components(:tea_tapioca).name,
      price_cents: -1
    )

    assert_not record.valid?
    assert_includes record.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "portion enum covers expected values" do
    assert_equal "half", order_item_components(:tea_classic_tapioca).portion
  end

  test "syncs shop from order item" do
    record = OrderItemComponent.create!(
      order_item: order_items(:tea_classic_regular),
      component: components(:tea_grass_jelly),
      component_name: components(:tea_grass_jelly).name,
      price_cents: 50
    )

    assert_equal order_items(:tea_classic_regular).shop, record.shop
  end

  test "snapshots component name" do
    record = OrderItemComponent.create!(
      order_item: order_items(:tea_classic_regular),
      component: components(:tea_cheese_foam),
      component_name: nil,
      price_cents: 75
    )

    assert_equal components(:tea_cheese_foam).name, record.component_name
  end

  test "formatted price defaults to MXN" do
    component = order_item_components(:tea_classic_tapioca)

    assert_equal "$0.50 MXN", component.formatted_price
  end
end
