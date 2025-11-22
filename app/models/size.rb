class Size < ApplicationRecord
  include ShopScoped
  include Monetizable

  monetizes :price_cents

  has_many :product_sizes, dependent: :restrict_with_exception
  has_many :products, through: :product_sizes

  scope :ordered, -> { order(position: :asc) }
  scope :available, -> { where(available: true) }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :shop_id, case_sensitive: false }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  normalizes :name, with: ->(value) { value.to_s.strip }
  normalizes :slug, with: ->(value) { value.to_s.strip.parameterize }
end
