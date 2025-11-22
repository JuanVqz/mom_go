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

      return failure(form:, error: locked_error) if user&.locked?

      unless user&.authenticate(form.password)
        newly_locked = user&.increment_failed_attempts!(threshold: lock_threshold)
        handle_lock_notification(user) if newly_locked
        return failure(form:, error: default_error)
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

    def locked_error
      "Account locked. Please reset your password or contact support."
    end

    def lock_threshold
      raw = ENV["AUTH_MAX_FAILED_ATTEMPTS"]
      value = raw.present? ? raw.to_i : Users::Credentials::DEFAULT_LOCK_THRESHOLD
      value.positive? ? value : Users::Credentials::DEFAULT_LOCK_THRESHOLD
    end

    def handle_lock_notification(user)
      return unless user

      user.issue_reset_password_token!
      AuthMailer.with(user:).account_locked.deliver_later
    end
  end
end
