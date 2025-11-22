class AuthMailer < ApplicationMailer
  def password_reset
    @user = params.fetch(:user)
    @shop = @user.shop
    @reset_url = edit_shops_password_reset_url(url_options_for(@shop).merge(token: @user.reset_password_token))

    mail(to: @user.email, subject: "Reset your MomGo password")
  end

  def account_locked
    @user = params.fetch(:user)
    @shop = @user.shop
    @reset_url = edit_shops_password_reset_url(url_options_for(@shop).merge(token: @user.reset_password_token))

    mail(to: @user.email, subject: "Your MomGo account is locked")
  end

  private

  def url_options_for(shop)
    defaults = (Rails.application.config.action_mailer.default_url_options || {}).symbolize_keys
    host = defaults[:host] || "lvh.me"
    defaults.merge(host: "#{shop.subdomain}.#{host}")
  end
end
