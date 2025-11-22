module Shops
  class PasswordResetsController < ApplicationController
    before_action :ensure_shop!
    before_action :require_token!, only: %i[edit update]

    def new
      @password_reset_request_form = PasswordResetRequestForm.new
    end

    def create
      result = Auth::GenerateResetToken.call(shop: Current.shop, params: password_reset_request_form_params)
      @password_reset_request_form = result.form

      if result.success?
        redirect_to new_shops_session_path, notice: t("auth.flash.password_resets.create")
      else
        flash.now[:alert] = result.error
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      unless Auth::ResetPassword.token_valid?(shop: Current.shop, token: token_param)
        redirect_to new_shops_password_reset_path, alert: t("auth.flash.password_resets.invalid_token")
        return
      end

      @password_reset_form = PasswordResetForm.new
    end

    def update
      result = Auth::ResetPassword.call(shop: Current.shop, token: token_param, params: password_reset_form_params)
      @password_reset_form = result.form

      if result.success?
        sign_in(result.user)
        redirect_to shops_dashboard_path, notice: t("auth.flash.password_resets.update")
      else
        flash.now[:alert] = result.error
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_reset_request_form_params
      params.fetch(:password_reset_request_form, {}).permit(:email)
    end

    def password_reset_form_params
      params.fetch(:password_reset_form, {}).permit(:password, :password_confirmation)
    end

    def token_param
      params[:token].presence
    end

    def require_token!
      return if token_param.present?

      redirect_to new_shops_password_reset_path, alert: t("auth.flash.password_resets.missing_token")
    end
  end
end
