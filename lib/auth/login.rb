module Auth
  class Login
    Result = Struct.new(:success?, :user, :error, :form, keyword_init: true)

    def self.call(shop:, params:, ip: nil)
      new(shop:, params:, ip:).call
    end

    def initialize(shop:, params:, ip: nil)
      @shop = shop
      @params = params.to_h
      @ip = ip
    end

    def call
      return shop_missing unless shop

      form = SessionForm.new(email: params[:email], password: params[:password])
      return failure(form:, error: "Enter both email and password.") unless form.valid?

      user = locate_user(form.normalized_email)

      unless user&.authenticate(form.password)
        user&.increment_failed_attempts!
        return failure(form:, error: default_error)
      end

      if user.locked?
        return failure(form:, error: "Account locked. Please reset your password or contact support.")
      end

      user.register_successful_sign_in!(ip: ip)
      success(user:, form:)
    end

    private

    attr_reader :shop, :params, :ip

    def locate_user(email)
      User.without_tenant_scope do
        User.find_by(shop_id: shop.id, email: email)
      end
    end

    def success(user:, form:)
      Result.new(success?: true, user:, form:, error: nil)
    end

    def failure(form:, error: default_error)
      Result.new(success?: false, user: nil, form:, error:)
    end

    def shop_missing
      Result.new(success?: false, user: nil, form: SessionForm.new, error: "Shop not found")
    end

    def default_error
      "Invalid email or password."
    end
  end
end
