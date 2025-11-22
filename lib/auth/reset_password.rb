module Auth
  class ResetPassword
    Result = Struct.new(:success?, :form, :error, :user, keyword_init: true)

    def self.call(shop:, token:, params:)
      new(shop:, token:, params:).call
    end

    def self.token_valid?(shop:, token:)
      new(shop:, token:, params: {}).send(:token_user).present?
    end

    def initialize(shop:, token:, params:)
      @shop = shop
      @token = token.to_s
      @params = params.to_h
    end

    def call
      return shop_missing unless shop

      form = PasswordResetForm.new(params)
      return failure(form:, error: I18n.t("auth.errors.reset_form_invalid")) unless form.valid?

      user = token_user
      return failure(form:, error: invalid_token_error) unless user

      user.password = form.password
      user.password_confirmation = form.password_confirmation
      user.failed_attempts = 0
      user.locked_at = nil
      user.reset_password_token = nil
      user.reset_password_sent_at = nil
      user.save!

      Result.new(success?: true, form:, error: nil, user: user)
    rescue ActiveRecord::RecordInvalid => e
      failure(form:, error: e.record.errors.full_messages.to_sentence)
    end

    private

    attr_reader :shop, :token, :params

    def token_user
      return nil if token.blank? || shop.blank?

      User.without_tenant_scope do
        user = User.find_by(shop_id: shop.id, reset_password_token: token)
        return nil unless user
        return nil if user.reset_password_token_expired?

        user
      end
    end

    def failure(form:, error:)
      Result.new(success?: false, form:, error:, user: nil)
    end

    def shop_missing
      Result.new(success?: false, form: PasswordResetForm.new, error: I18n.t("auth.errors.shop_missing"), user: nil)
    end

    def invalid_token_error
      I18n.t("auth.flash.password_resets.invalid_token")
    end
  end
end
