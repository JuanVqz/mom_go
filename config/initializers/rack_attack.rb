require "rack/attack"

module RackAttackHelpers
  module_function

  def login_request?(req)
    req.post? && req.path == "/session"
  end

  def password_reset_request?(req)
    req.post? && req.path == "/password_reset"
  end

  def throttle_discriminator(req)
    [req.ip, shop_subdomain(req.host)].join(":")
  end

  def shop_subdomain(host)
    host.to_s.split(".").first.presence || "global"
  end
end

Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

login_limit = Rails.configuration.x.auth.login_rate_limit
login_period = Rails.configuration.x.auth.login_rate_limit_period
reset_limit = Rails.configuration.x.auth.reset_rate_limit
reset_period = Rails.configuration.x.auth.reset_rate_limit_period

Rack::Attack.throttle("shops/logins/ip", limit: login_limit, period: login_period) do |req|
  next unless RackAttackHelpers.login_request?(req)

  RackAttackHelpers.throttle_discriminator(req)
end

Rack::Attack.throttle("shops/password_resets/ip", limit: reset_limit, period: reset_period) do |req|
  next unless RackAttackHelpers.password_reset_request?(req)

  RackAttackHelpers.throttle_discriminator(req)
end

Rack::Attack.safelist("allow-health-check") { |req| req.path == "/up" }

Rack::Attack.throttled_responder = lambda do |request|
  match_data = request.env["rack.attack.match_data"] || {}
  payload = {
    path: request.path,
    ip: request.ip,
    shop_subdomain: RackAttackHelpers.shop_subdomain(request.host),
    rule: request.env["rack.attack.matched"],
    limit: match_data[:limit],
    period: match_data[:period]
  }
  Auth::Instrumentation.rate_limit(payload)

  retry_after = (match_data[:period] || 60).to_s
  message = I18n.t("auth.flash.rate_limit")
  [
    429,
    { "Content-Type" => "text/plain", "Retry-After" => retry_after },
    [message]
  ]
end
