class OrderItem < ApplicationRecord
  include MomGo::TenantScoped
  include Monetizable

  monetizes :price_cents

  belongs_to :order
  belongs_to :product
  belongs_to :product_size, optional: true
  has_many :order_item_components, dependent: :restrict_with_exception

  enum :status, {
    pending: 0,
    preparing: 1,
    ready: 2,
    completed: 3,
    cancelled: 4
  }

  validates :product_name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :shop_matches_order

  before_validation :sync_shop_from_order
  before_validation :snapshot_catalog_names

  private

  def sync_shop_from_order
    return unless order

    self.shop ||= order.shop
  end

  def snapshot_catalog_names
    self.product_name ||= product&.name
    self.size_name ||= product_size&.size&.name
  end

  def shop_matches_order
    return unless order && shop
    return if order.shop_id == shop_id

    errors.add(:shop, "must match order shop")
  end
end
