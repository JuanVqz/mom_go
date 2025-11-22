class PasswordResetRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string

  validates :email, presence: true

  def normalized_email
    email.to_s.strip.downcase
  end
end
