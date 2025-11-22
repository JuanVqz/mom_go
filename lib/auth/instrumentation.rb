require "json"

module Auth
  module Instrumentation
    module_function

    def login(payload = {})
      emit("auth.login", payload)
    end

    def rate_limit(payload = {})
      emit("auth.rate_limit", payload)
    end

    def emit(event, payload)
      data = sanitize(payload)
      Rails.logger.info("[#{event}] #{data.to_json}")
      ActiveSupport::Notifications.instrument(event, data)
    end

    def sanitize(payload)
      data = (payload || {}).dup
      shop = data.delete(:shop)
      user = data.delete(:user)

      if shop
        data[:shop_id] ||= shop.id
        data[:shop_subdomain] ||= shop.subdomain
      end

      if user
        data[:user_id] ||= user.id
        data[:email] ||= user.email
      end

      data.compact
    end
  end
end
