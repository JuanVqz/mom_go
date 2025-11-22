class ProductSize < ApplicationRecord
  include ShopScoped
  include Monetizable

  monetizes :price_cents

  belongs_to :product
  belongs_to :size

  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: [:size_id, :shop_id] }
end
