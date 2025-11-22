module AuthenticationHelpers
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user

    helper_method :current_user
  end

  private

  def set_current_user
    Current.user = nil
    return unless Current.shop && session[:user_id].present?

    Current.user = User.without_tenant_scope do
      User.find_by(id: session[:user_id], shop_id: Current.shop.id)
    end
  end

  def current_user
    Current.user
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
    Current.user = user
  end

  def sign_out
    reset_session
    Current.user = nil
  end

  def require_authentication
    return if current_user.present?

    redirect_to new_shops_session_path, alert: I18n.t("auth.flash.helpers.require_authentication")
  end

  def ensure_shop!
    return if Current.shop.present?

    render plain: I18n.t("auth.errors.shop_missing"), status: :not_found
  end

  def redirect_authenticated_user
    redirect_to shops_dashboard_path if current_user.present?
  end
end
