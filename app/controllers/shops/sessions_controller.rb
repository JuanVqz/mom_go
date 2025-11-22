module Shops
  class SessionsController < ApplicationController
    before_action :ensure_shop!
    before_action :redirect_authenticated_user, only: %i[new create]

    def new
      @session_form = SessionForm.new
    end

    def create
      result = Auth::Login.call(shop: Current.shop, params: session_form_params, ip: request.remote_ip)

      if result.success?
        sign_in(result.user)
        redirect_to shops_dashboard_path, notice: t("auth.flash.sessions.create")
      else
        @session_form = result.form
        flash.now[:alert] = result.error
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      ensure_shop!
      sign_out
      redirect_to new_shops_session_path, notice: t("auth.flash.sessions.destroy")
    end

    private

    def session_form_params
      params.require(:session_form).permit(:email, :password)
    end
  end
end
