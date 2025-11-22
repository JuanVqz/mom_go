module Auth
  class GenerateResetToken
    Result = Struct.new(:success?, :form, :error, keyword_init: true)

    def self.call(shop:, params:)
      new(shop:, params:).call
    end

    def initialize(shop:, params:)
      @shop = shop
      @params = params.to_h
    end

    def call
      return shop_missing unless shop

      form = PasswordResetRequestForm.new(email: params[:email])
      return failure(form:, error: "Enter your email address.") unless form.valid?

      user = locate_user(form.normalized_email)
      if user
        user.issue_reset_password_token!
        AuthMailer.with(user:).password_reset.deliver_later
      end

      success(form:)
    end

    private

    attr_reader :shop, :params

    def locate_user(email)
      User.without_tenant_scope do
        User.find_by(shop_id: shop.id, email: email)
      end
    end

    def success(form:)
      Result.new(success?: true, form:, error: nil)
    end

    def failure(form:, error:)
      Result.new(success?: false, form:, error:)
    end

    def shop_missing
      Result.new(success?: false, form: PasswordResetRequestForm.new, error: "Shop not found")
    end
  end
end
