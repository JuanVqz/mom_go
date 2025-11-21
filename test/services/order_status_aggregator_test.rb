require "test_helper"

class OrderStatusAggregatorTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "marks order ready when all items ready or completed" do
    order = orders(:tea_pending)
    first_item = order_items(:tea_classic_regular)
    first_item.update!(status: :ready)

    order.order_items.create!(
      shop: order.shop,
      order:,
      product: products(:matcha_cloud),
      product_name: "Matcha Cloud",
      price_cents: 650,
      status: :completed
    )

    OrderStatusAggregator.call(order.reload, persist: true)

    order.reload
    assert_equal "ready", order.status
    assert_equal 2, order.total_item_count
    assert_not_nil order.ready_at
  end

  test "cancels order when every item cancelled" do
    order = orders(:tea_pending)
    order.order_items.update_all(status: OrderItem.statuses[:cancelled])

    OrderStatusAggregator.call(order.reload, persist: true)

    order.reload
    assert_equal "cancelled", order.status
    assert_equal order.order_items.count, order.total_item_count
  end
end
