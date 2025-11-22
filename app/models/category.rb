class Category < ApplicationRecord
  include ShopScoped

  has_many :product_categories, dependent: :restrict_with_exception
  has_many :products, through: :product_categories

  scope :ordered, -> { order(position: :asc) }
  scope :available, -> { where(available: true) }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :shop_id, case_sensitive: false }

  normalizes :name, with: ->(value) { value.to_s.strip }
  normalizes :slug, with: ->(value) { value.to_s.strip.parameterize }
end
