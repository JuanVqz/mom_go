class PasswordResetForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :password, :string
  attribute :password_confirmation, :string

  validates :password, presence: true, length: { minimum: 8 }, confirmation: true
  validates :password_confirmation, presence: true
end
