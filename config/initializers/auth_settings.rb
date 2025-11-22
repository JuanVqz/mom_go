module AuthSettings
  module_function

  def positive_integer_env(key, default)
    raw = ENV[key]
    return default if raw.blank?

    value = raw.to_i
    value.positive? ? value : default
  end
end

Rails.application.configure do
  config.x.auth ||= ActiveSupport::OrderedOptions.new

  config.x.auth.login_rate_limit = AuthSettings.positive_integer_env("AUTH_LOGIN_RATE_LIMIT", 10)
  config.x.auth.login_rate_limit_period = AuthSettings.positive_integer_env("AUTH_LOGIN_RATE_LIMIT_PERIOD", 60)

  config.x.auth.reset_rate_limit = AuthSettings.positive_integer_env("AUTH_RESET_RATE_LIMIT", 5)
  config.x.auth.reset_rate_limit_period = AuthSettings.positive_integer_env("AUTH_RESET_RATE_LIMIT_PERIOD", 60)
end
