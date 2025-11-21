class Shop < ApplicationRecord
  has_many :users, dependent: :restrict_with_exception
  has_many :categories, dependent: :restrict_with_exception
  has_many :products, dependent: :restrict_with_exception
  has_many :sizes, dependent: :restrict_with_exception
  has_many :components, dependent: :restrict_with_exception
  has_many :product_categories, dependent: :restrict_with_exception
  has_many :product_sizes, dependent: :restrict_with_exception
  has_many :product_components, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: { case_sensitive: false }

  normalizes :subdomain, with: ->(subdomain) { subdomain.to_s.strip.parameterize }
end
