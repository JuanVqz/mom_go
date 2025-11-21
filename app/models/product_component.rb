class ProductComponent < ApplicationRecord
  include MomGo::TenantScoped
  include Monetizable

  monetizes :price_cents

  belongs_to :product
  belongs_to :component

  enum :default_portion, {
    none: 0,
    quarter: 1,
    half: 2,
    three_quarters: 3,
    full: 4
  }, prefix: :default_portion

  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: [:component_id, :shop_id] }
end
