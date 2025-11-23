class OrderCart
  attr_reader :shop, :session

  def initialize(session:, shop:)
    @session = session
    @shop = shop
    ensure_store!
  end

  def items
    data["items"].dup
  end

  def add_item(product_id:, product_size_id:, component_portions: {}, ingredient_portions: {})
    normalized_portions = normalize_portions(component_portions)
    normalized_ingredients = normalize_portions(ingredient_portions)
    item = {
      "id" => SecureRandom.uuid,
      "product_id" => product_id,
      "product_size_id" => product_size_id,
      "component_portions" => normalized_portions,
      "ingredient_portions" => normalized_ingredients
    }

    data["items"] << item
    persist!
    item
  end

  def remove_item(id)
    data["items"].reject! { |item| item["id"] == id }
    cleanup_if_empty!
    persist!
  end

  def clear
    cart_store.delete(shop_key)
    cleanup_cart!
    persist!
  end

  def empty?
    data["items"].empty?
  end

  private

  def normalize_portions(portions)
    portions.to_h.transform_keys(&:to_s).transform_values(&:to_s)
  end

  def ensure_store!
    cart_store
    data
  end

  def cart_store
    session[:cart] ||= {}
  end

  def data
    cart_store[shop_key] ||= { "items" => [] }
  end

  def cleanup_if_empty!
    return unless data["items"].empty?

    cart_store.delete(shop_key)
    cleanup_cart!
  end

  def cleanup_cart!
    session.delete(:cart) if cart_store.empty?
  end

  def persist!
    session[:cart] = cart_store
  end

  def shop_key
    shop.id.to_s
  end
end
