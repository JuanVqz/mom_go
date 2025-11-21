require "test_helper"

class OrderBuilderTest < ActiveSupport::TestCase
  setup { Current.reset }
  teardown { Current.reset }

  test "builds order with catalog snapshots and totals" do
    shop = shops(:tea)

    payload = {
      number: "T-2005",
      currency: "MXN",
      tax_total_cents: 165,
      discount_total_cents: 0,
      items: [
        {
          product_id: products(:classic_milk_tea).id,
          product_size_id: product_sizes(:classic_regular).id,
          components: [
            { component_id: components(:tea_tapioca).id, portion: "half" }
          ]
        },
        {
          product_id: products(:matcha_cloud).id,
          components: [
            { component_id: components(:tea_cheese_foam).id }
          ],
          status: "preparing"
        }
      ]
    }

    order = OrderBuilder.call(shop:, cart_payload: payload)

    assert order.persisted?
    assert_equal shop, order.shop
    assert_equal 2, order.order_items.count

    classic_item = order.order_items.detect { |item| item.product_id == products(:classic_milk_tea).id }
    assert_equal "Classic Milk Tea", classic_item.product_name
    assert_equal "half", classic_item.order_item_components.first.portion

    assert_equal 2, order.total_item_count
    assert_equal "preparing", order.status

    expected_items_total = 500 + 0 + 50 + 650 + 0 + 0
    assert_equal expected_items_total, order.items_total_cents
    assert_equal expected_items_total + payload[:tax_total_cents], order.total_cents
  end

  test "raises when cart has no items" do
    shop = shops(:tea)

    assert_raises(ArgumentError) do
      OrderBuilder.call(shop:, cart_payload: { number: "EMPTY-1" })
    end
  end
end
