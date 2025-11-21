class Shop < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }

  normalizes :subdomain, with: ->(subdomain) { subdomain.to_s.strip.parameterize }
end
