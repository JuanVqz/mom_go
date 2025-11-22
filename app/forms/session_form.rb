class SessionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :password, :string

  validates :email, :password, presence: true

  def normalized_email
    email.to_s.strip.downcase
  end
end
