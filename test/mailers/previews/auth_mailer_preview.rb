class AuthMailerPreview < ActionMailer::Preview
  def password_reset
    AuthMailer.with(user: sample_user).password_reset
  end

  def account_locked
    AuthMailer.with(user: sample_user).account_locked
  end

  private

  def sample_user
    persisted = Shop.first&.users&.first

    if persisted
      user = persisted.dup
      user.shop = persisted.shop
    else
      shop = Shop.first || Shop.new(name: "Preview Shop", subdomain: "preview-shop")
      user = User.new(name: "Preview Staff", email: "staff@#{shop.subdomain}.test", shop: shop)
    end

    user.reset_password_token ||= SecureRandom.urlsafe_base64(16)
    user
  end
end
