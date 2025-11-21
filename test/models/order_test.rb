require "test_helper"

class OrderTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers
  setup { Current.reset }
  teardown { Current.reset }

  test "requires number unique per shop" do
    order = Order.new(shop: shops(:tea), number: orders(:tea_pending).number)

    assert_not order.valid?
    assert_includes order.errors[:number], "has already been taken"
  end

  test "monetary totals must be non-negative" do
    order = Order.new(
      shop: shops(:tea),
      number: "NEG-1",
      items_total_cents: -1,
      discount_total_cents: -1,
      tax_total_cents: -1,
      total_cents: -1,
      total_item_count: -1,
      currency: "MXN"
    )

    assert_not order.valid?
    %i[items_total_cents discount_total_cents tax_total_cents total_cents total_item_count].each do |attr|
      assert_includes order.errors[attr], "must be greater than or equal to 0"
    end
  end

  test "normalizes currency to uppercase" do
    order = orders(:tea_pending)
    order.update!(currency: "mxn")

    assert_equal "MXN", order.currency
  end

  test "defaults currency to MXN" do
    order = Order.new(shop: shops(:tea), number: "DEF-1")

    assert_equal "MXN", order.currency
  end

  test "monetized helpers expose totals" do
    order = orders(:tea_pending)
    order.update!(items_total_cents: 12345, currency: "MXN")

    assert_equal BigDecimal("123.45"), order.items_total
    assert_equal "$123.45 MXN", order.formatted_items_total
  end

  test "ready_at stamps when transitioning to ready" do
    order = orders(:tea_pending)
    ready_time = Time.zone.parse("2025-11-21 12:00:00")

    travel_to ready_time do
      order.accepted!
      assert_nil order.reload.ready_at

      order.ready!
      assert_equal ready_time, order.reload.ready_at
    end

    travel_to ready_time + 1.hour do
      order.completed!
      assert_equal ready_time, order.reload.ready_at
    end
  end
end
