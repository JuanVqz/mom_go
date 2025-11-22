module Middleware
  class ShopContextMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Current.reset
      Current.shop = locate_shop(ActionDispatch::Request.new(env))

      @app.call(env)
    ensure
      Current.reset
    end

    private

    def locate_shop(request)
      subdomain = request.subdomains.first
      return nil if subdomain.blank?

      Shop.find_by(subdomain: subdomain)
    end
  end
end
