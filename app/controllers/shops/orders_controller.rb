module Shops
  class OrdersController < ApplicationController
    include CartSupport

    before_action :load_catalog, only: %i[new checkout]
    before_action :ensure_cart_present!, only: %i[checkout commit]
    helper_method :portion_options, :portion_options_for

    def new
      assign_cart_presenters(show_all_extras: false)
    end

    def checkout
      assign_cart_presenters(show_all_extras: true)
    end

    def commit
      payload = CartPayloadBuilder.new(
        shop: Current.shop,
        cart_items: current_cart.items,
        number: next_order_number,
        currency: default_currency,
        tax_total_cents: 0,
        discount_total_cents: 0
      ).call

      order = OrderBuilder.call(shop: Current.shop, cart_payload: payload)
      current_cart.clear

      redirect_to shops_order_path(order), notice: t("orders.flash.created")
    rescue ActiveRecord::RecordInvalid, ArgumentError => e
      redirect_to checkout_shops_orders_path, alert: e.message
    end

    def show
      @order = Current.shop.orders.includes(order_items: :order_item_components).find(params[:id])
    end

    private

    def assign_cart_presenters(show_all_extras: false)
      @cart_items = build_cart_items(show_all_extras: show_all_extras)
      @cart_empty = @cart_items.empty?
    end

    def build_cart_items(show_all_extras: false)
      index = @products&.index_by(&:id) || load_products_index

      current_cart.items.map do |item|
        product = index[item["product_id"].to_i]
        next unless product

        {
          id: item["id"],
          product: product,
          size: product.product_sizes.find { |ps| ps.id == item["product_size_id"].to_i },
          ingredients: ingredients_for(product, item),
          extras: extras_for(product, item, show_all: show_all_extras)
        }
      end.compact
    end

    def ingredients_for(product, item)
      overrides = item["ingredient_portions"] || {}

      product.product_components.select(&:ingredient?).map do |ingredient|
        portion = overrides[ingredient.component_id.to_s].presence || ingredient.default_portion
        {
          product_component: ingredient,
          portion: portion
        }
      end
    end

    def extras_for(product, item, show_all: false)
      selections = item["component_portions"] || {}

      product.product_components.select(&:extra?).map do |product_component|
        portion = selections[product_component.component_id.to_s]
        if portion.blank?
          next unless show_all
          portion = "none"
        end

        {
          product_component: product_component,
          portion: portion.presence || "none"
        }
      end.compact
    end

    def load_catalog
      @products = Current.shop.products.includes(:product_sizes, product_components: :component).order(:position)
    end

    def load_products_index
      Current.shop.products.includes(:product_sizes, product_components: :component).index_by(&:id)
    end

    def ensure_cart_present!
      return unless current_cart.empty?

      redirect_to new_shops_order_path, alert: t("orders.cart.empty")
    end

    def next_order_number
      timestamp = Time.current.strftime("%Y%m%d%H%M%S")
      "#{Current.shop.subdomain.upcase}-#{timestamp}"
    end

    def default_currency
      "MXN"
    end

    def portion_options
      @portion_options ||= OrderItemComponent.portions.keys.map { |portion| [portion.humanize, portion] }
    end

    def portion_options_for(product_component)
      return portion_options unless product_component.required?

      @portion_options_without_none ||= portion_options.reject { |option| option.last == "none" }
    end
  end
end
