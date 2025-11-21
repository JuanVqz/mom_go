require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module MomGo
  class Application < Rails::Application
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    require "middleware/mom_go/shop_context_middleware"
    config.middleware.use MomGo::ShopContextMiddleware

    config.time_zone = "Central Time (US & Canada)"
  end
end
