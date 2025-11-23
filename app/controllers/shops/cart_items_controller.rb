module Shops
  class CartItemsController < ApplicationController
    include CartSupport

    def create
      product = load_product
      component_portions = sanitize_component_portions(product)
      ingredient_portions = sanitize_ingredient_portions(product)
      size_id = cart_item_params[:product_size_id].presence
      validate_product_size!(product, size_id)

      current_cart.add_item(
        product_id: product.id,
        product_size_id: size_id&.to_i,
        component_portions: component_portions,
        ingredient_portions: ingredient_portions
      )

      redirect_to new_shops_order_path, notice: t("orders.cart.item_added")
    rescue ActiveRecord::RecordNotFound, ArgumentError => e
      redirect_to new_shops_order_path, alert: e.message
    end

    def destroy
      current_cart.remove_item(params[:id])
      redirect_to new_shops_order_path, notice: t("orders.cart.item_removed")
    end

    private

    def load_product
      product_id = cart_item_params[:product_id]
      raise ArgumentError, "Product is required" if product_id.blank?

      Current.shop.products.includes(:product_sizes, product_components: :component).find(product_id)
    end

    def cart_item_params
      params.require(:cart_item).permit(:product_id, :product_size_id, component_portions: {}, ingredient_portions: {})
    end

    def sanitize_component_portions(product)
      selections = (cart_item_params[:component_portions] || {}).to_h
      allowed_portions = OrderItemComponent.portions.keys

      extras = product.product_components.select(&:extra?)
      extras_by_component_id = extras.index_by { |pc| pc.component_id.to_s }

      selections.each_with_object({}) do |(component_id, portion), result|
        component_key = component_id.to_s
        next unless extras_by_component_id.key?(component_key)

        portion_value = portion.to_s
        next unless allowed_portions.include?(portion_value)
        next if portion_value == "none"

        result[component_key] = portion_value
      end
    end

    def sanitize_ingredient_portions(product)
      selections = (cart_item_params[:ingredient_portions] || {}).to_h
      allowed_portions = OrderItemComponent.portions.keys

      ingredients = product.product_components.select(&:ingredient?)
      ingredients_by_component_id = ingredients.index_by { |pc| pc.component_id.to_s }

      selections.each_with_object({}) do |(component_id, portion), result|
        component_key = component_id.to_s
        product_component = ingredients_by_component_id[component_key]
        next unless product_component

        portion_value = portion.to_s
        next unless allowed_portions.include?(portion_value)
        next if portion_value == product_component.default_portion.to_s
        next if portion_value == "none" && product_component.required?

        result[component_key] = portion_value
      end
    end

    def validate_product_size!(product, size_id)
      if product.product_sizes.any? && size_id.blank?
        raise ArgumentError, t("orders.cart.size_required")
      end

      return if size_id.blank?

      exists = product.product_sizes.any? { |ps| ps.id == size_id.to_i }
      raise ArgumentError, t("orders.cart.size_unavailable") unless exists
    end
  end
end
