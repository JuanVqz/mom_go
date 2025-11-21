class OrderBuilder
  def self.call(shop:, cart_payload:)
    new(shop:, cart_payload:).call
  end

  def initialize(shop:, cart_payload:)
    @shop = shop
    @payload = cart_payload.deep_symbolize_keys
  end

  def call
    Current.set(shop:) do
      Order.transaction do
        order = build_order
        build_items(order)
        compute_totals(order)
        OrderStatusAggregator.call(order)
        order.save!
        order
      end
    end
  end

  private

  attr_reader :shop, :payload

  def build_order
    Order.new(
      shop:,
      number: payload.fetch(:number),
      currency: payload[:currency],
      discount_total_cents: payload.fetch(:discount_total_cents, 0),
      tax_total_cents: payload.fetch(:tax_total_cents, 0)
    )
  end

  def build_items(order)
    items_payload = Array(payload[:items])
    raise ArgumentError, "cart must include at least one item" if items_payload.empty?

    items_payload.each do |item_payload|
      build_item(order, item_payload)
    end
  end

  def build_item(order, item_payload)
    item_attrs = item_payload.deep_symbolize_keys
    product = find_product(item_attrs.fetch(:product_id))
    product_size = find_product_size(item_attrs[:product_size_id], product)

    order_item = order.order_items.build(
      product:,
      product_size:,
      product_name: product.name,
      size_name: product_size&.size&.name,
      status: item_attrs[:status] || :pending
    )

    components_total = build_components(order_item, product, Array(item_attrs[:components]))
    base_price = product.base_price_cents + (product_size&.price_cents || 0)
    order_item.price_cents = base_price + components_total
  end

  def build_components(order_item, product, components_payload)
    components_payload.sum do |component_attrs|
      attrs = component_attrs.deep_symbolize_keys
      product_component = find_product_component(product, attrs.fetch(:component_id))
      component = product_component.component
      portion = attrs[:portion]&.to_sym || product_component.default_portion

      order_item.order_item_components.build(
        component:,
        component_name: component.name,
        portion:,
        price_cents: product_component.price_cents
      )

      product_component.price_cents
    end
  end

  def compute_totals(order)
    order.items_total_cents = order.order_items.sum(&:price_cents)
    order.total_cents = order.items_total_cents - order.discount_total_cents + order.tax_total_cents
  end

  def find_product(product_id)
    Product.without_tenant_scope do
      Product.find_by!(shop_id: shop.id, id: product_id)
    end
  end

  def find_product_size(product_size_id, product)
    return if product_size_id.blank?

    ProductSize.without_tenant_scope do
      ProductSize.find_by!(shop_id: shop.id, id: product_size_id, product_id: product.id)
    end
  end

  def find_product_component(product, component_id)
    ProductComponent.without_tenant_scope do
      ProductComponent.find_by!(shop_id: shop.id, product_id: product.id, component_id:)
    end
  end
end
