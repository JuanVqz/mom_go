module Auth
  module Metrics
    module_function

    def increment_failed_login(shop:, reason: :unknown)
      return unless shop

      key = failed_login_key(shop.id)
      store = cache_store
      store.fetch(key, expires_in: 24.hours, raw: true) { 0 }
      store.increment(key, 1, raw: true)
      ActiveSupport::Notifications.instrument(
        "auth.metrics.failed_login",
        shop_id: shop.id,
        shop_subdomain: shop.subdomain,
        reason: reason
      )
    end

    def failed_login_count(shop:)
      cache_store.read(failed_login_key(shop.id)).to_i
    end

    def reset_failed_login!(shop:)
      cache_store.delete(failed_login_key(shop.id))
    end

    def failed_login_key(shop_id)
      "metrics:auth:failed_login:shop:#{shop_id}"
    end

    def cache_store
      if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
        @memory_store ||= ActiveSupport::Cache::MemoryStore.new
      else
        Rails.cache
      end
    end
  end
end
