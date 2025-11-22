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
      email = form.normalized_email

      unless form.valid?
        instrument_login(status: :invalid_params, email: email)
        return failure(form:, error: I18n.t("auth.errors.missing_params"))
      end

      user = locate_user(email)

      if user&.locked?
        instrument_login(status: :locked, user:, email: email)
        Auth::Metrics.increment_failed_login(shop:, reason: :locked)
        return failure(form:, error: locked_error)
      end

      unless user&.authenticate(form.password)
        newly_locked = user&.increment_failed_attempts!(threshold: lock_threshold)
        handle_lock_notification(user) if newly_locked

        reason = newly_locked ? :locked : :invalid_credentials
        instrument_login(status: newly_locked ? :locked : :failure, user:, email: email, metadata: { reason:, newly_locked: newly_locked })
        Auth::Metrics.increment_failed_login(shop:, reason: reason)
        return failure(form:, error: default_error)
      end

      user.register_successful_sign_in!(ip: ip)
      instrument_login(status: :success, user:, email: email)
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
      instrument_login(status: :shop_missing, email: params[:email])
      Result.new(success?: false, user: nil, form: SessionForm.new, error: I18n.t("auth.errors.shop_missing"))
    end

    def default_error
      I18n.t("auth.errors.invalid_credentials")
    end

    def locked_error
      I18n.t("auth.errors.locked")
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

    def instrument_login(status:, email:, user: nil, metadata: {})
      Auth::Instrumentation.login(
        status: status,
        shop: shop,
        user: user,
        email: email,
        ip: ip,
        metadata: metadata.compact
      )
    end
  end
end
