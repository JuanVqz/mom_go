class OrderStatusAggregator
  READY_STATES = %w[ready completed].freeze

  def self.call(order, persist: false)
    new(order, persist:).call
  end

  def initialize(order, persist: false)
    @order = order
    @persist = persist
  end

  def call
    apply_totals
    apply_status
    persist_changes if persist?
    order
  end

  private

  attr_reader :order

  def persist?
    @persist
  end

  def apply_totals
    order.total_item_count = scoped_items.size
  end

  def apply_status
    new_status = derive_status(scoped_items)
    order.status = new_status if new_status
  end

  def scoped_items
    @scoped_items ||= order.order_items.reject(&:marked_for_destruction?)
  end

  def derive_status(items)
    statuses = items.map { |item| item.status.to_s.presence || "pending" }

    return :pending if statuses.empty?
    return :cancelled if statuses.all? { |status| status == "cancelled" }
    return :completed if statuses.all? { |status| status == "completed" }
    return :ready if statuses.all? { |status| READY_STATES.include?(status) }
    return :preparing if statuses.any? { |status| status == "preparing" }

    :pending
  end

  def persist_changes
    order.save! if order.changed?
  end
end
