class OrderItemComponent < ApplicationRecord
  include MomGo::TenantScoped
  include Monetizable

  monetizes :price_cents

  belongs_to :order_item
  belongs_to :component, optional: true

  enum :portion, {
    full: 0,
    three_quarters: 1,
    half: 2,
    quarter: 3,
    none: 4
  }, prefix: :portion

  validates :component_name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :shop_matches_order_item

  before_validation :sync_shop_from_order_item
  before_validation :snapshot_component_name

  private

  def sync_shop_from_order_item
    return unless order_item

    self.shop ||= order_item.shop
  end

  def snapshot_component_name
    self.component_name ||= component&.name
  end

  def shop_matches_order_item
    return unless order_item && shop
    return if order_item.shop_id == shop_id

    errors.add(:shop, :shop_must_match_order_item)
  end
end
