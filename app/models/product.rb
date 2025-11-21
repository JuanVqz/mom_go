class Product < ApplicationRecord
  include MomGo::TenantScoped
  include Monetizable

  monetizes :base_price_cents

  has_many :product_categories, dependent: :restrict_with_exception
  has_many :categories, through: :product_categories
  has_many :product_sizes, dependent: :restrict_with_exception
  has_many :sizes, through: :product_sizes
  has_many :product_components, dependent: :restrict_with_exception
  has_many :components, through: :product_components

  scope :ordered, -> { order(position: :asc) }
  scope :available, -> { where(available: true) }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :shop_id, case_sensitive: false }
  validates :base_price_cents, numericality: { greater_than_or_equal_to: 0 }

  normalizes :name, with: ->(value) { value.to_s.strip }
  normalizes :slug, with: ->(value) { value.to_s.strip.parameterize }
end
