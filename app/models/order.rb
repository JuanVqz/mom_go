class Order < ApplicationRecord
  include MomGo::TenantScoped
  include Monetizable

  monetizes :items_total_cents, :discount_total_cents, :tax_total_cents, :total_cents, currency_attribute: :currency

  has_many :order_items, dependent: :restrict_with_exception

  enum :status, {
    pending: 0,
    accepted: 1,
    preparing: 2,
    ready: 3,
    completed: 4,
    cancelled: 5
  }

  attribute :currency, default: "MXN"
  normalizes :currency, with: ->(value) { value.to_s.strip.upcase }

  validates :number, presence: true, uniqueness: { scope: :shop_id }
  validates :currency, presence: true, length: { is: 3 }
  validates :items_total_cents, :discount_total_cents, :tax_total_cents, :total_cents,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :total_item_count, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  before_save :stamp_ready_at

  private

  def stamp_ready_at
    return unless will_save_change_to_status?
    return unless ready?

    self.ready_at ||= Time.current
  end
end
