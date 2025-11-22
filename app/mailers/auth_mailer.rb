class AuthMailer < ApplicationMailer
  def password_reset
    prepare_context(params.fetch(:user))
    @reset_expiry_minutes = (Users::Credentials::RESET_TOKEN_TTL / 60).to_i

    mail(to: @user.email, subject: t(".subject", brand: @brand))
  end

  def account_locked
    prepare_context(params.fetch(:user))

    mail(to: @user.email, subject: t(".subject", brand: @brand))
  end

  private

  def prepare_context(user)
    @user = user
    @shop = user.shop
    @brand = brand_name
    @reset_url = edit_shops_password_reset_url(url_options_for(@shop).merge(token: user.reset_password_token))
  end

  def url_options_for(shop)
    defaults = (Rails.application.config.action_mailer.default_url_options || {}).symbolize_keys
    host = defaults[:host] || "lvh.me"
    defaults.merge(host: "#{shop.subdomain}.#{host}")
  end

  def brand_name
    I18n.t("auth.brand_name")
  end
end
