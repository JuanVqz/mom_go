class ProductCategory < ApplicationRecord
  include ShopScoped

  belongs_to :product
  belongs_to :category

  validates :product_id, uniqueness: { scope: [:category_id, :shop_id] }
end
