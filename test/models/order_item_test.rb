require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "requires product_name when no snapshot available" do
    order_item = OrderItem.new(order: orders(:tea_pending), price_cents: 100)

    assert_not order_item.valid?
    assert_includes order_item.errors[:product_name], "can't be blank"
  end

  test "price cents must be non-negative" do
    order_item = OrderItem.new(
      order: orders(:tea_pending),
      product: products(:classic_milk_tea),
      product_name: products(:classic_milk_tea).name,
      price_cents: -1
    )

    assert_not order_item.valid?
    assert_includes order_item.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "syncs shop from order" do
    order_item = OrderItem.create!(
      order: orders(:tea_pending),
      product: products(:classic_milk_tea),
      product_name: products(:classic_milk_tea).name,
      price_cents: 500
    )

    assert_equal orders(:tea_pending).shop, order_item.shop
  end

  test "snapshots names from catalog" do
    order = orders(:tea_pending)
    order_item = OrderItem.create!(
      order: order,
      product: products(:classic_milk_tea),
      product_size: product_sizes(:classic_regular),
      product_name: nil,
      size_name: nil,
      price_cents: 500
    )

    assert_equal products(:classic_milk_tea).name, order_item.product_name
    assert_equal product_sizes(:classic_regular).size.name, order_item.size_name
  end

  test "status enum includes ready" do
    assert_equal "ready", order_items(:tea_matcha_large).status
  end
end
