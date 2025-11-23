class CartPayloadBuilder
  def initialize(shop:, cart_items:, number:, currency: "MXN", tax_total_cents: 0, discount_total_cents: 0)
    @shop = shop
    @cart_items = cart_items
    @number = number
    @currency = currency
    @tax_total_cents = tax_total_cents
    @discount_total_cents = discount_total_cents
  end

  def call
    {
      number: number,
      currency: currency,
      tax_total_cents: tax_total_cents,
      discount_total_cents: discount_total_cents,
      items: build_items
    }
  end

  private

  attr_reader :shop, :cart_items, :number, :currency, :tax_total_cents, :discount_total_cents

  def build_items
    return [] if cart_items.blank?

    product_scope = shop.products.includes(:product_sizes, product_components: :component)

    cart_items.map do |item|
      product = product_scope.find(item.fetch("product_id"))
      product_size_id = item["product_size_id"].presence
      product_size = product_size_id.present? ? product.product_sizes.find { |ps| ps.id == product_size_id.to_i } : nil

      {
        product_id: product.id,
        product_size_id: product_size&.id,
        components: components_for(product, item)
      }
    end
  end

  def components_for(product, item)
    extras_portions = item.fetch("component_portions", {})
    ingredient_portions = item.fetch("ingredient_portions", {})

    product.product_components.map do |product_component|
      component_key = product_component.component_id.to_s

      if product_component.ingredient?
        portion = ingredient_portions[component_key].presence || product_component.default_portion
        next if portion == "none" && product_component.required?

        build_component_payload(product_component, portion)
      else
        portion = extras_portions[component_key]
        next if portion.blank? || portion == "none"

        build_component_payload(product_component, portion)
      end
    end.compact
  end

  def build_component_payload(product_component, portion)
    portion_value = portion.to_s
    {
      component_id: product_component.component_id,
      portion: portion_value
    }
  end
end
