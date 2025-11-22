class User < ApplicationRecord
  include MomGo::TenantScoped
  include Users::Credentials

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :shop_id, case_sensitive: false }

  normalizes :name, with: ->(name) { name.to_s.strip }
  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
end
