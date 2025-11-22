module Middleware
  class CurrentShopResolverMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      Current.reset
      request = ActionDispatch::Request.new(env)
      shop = locate_shop(request)

      return not_found_response unless shop

      Current.shop = shop
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

    def not_found_response
      body = not_found_body
      [
        Rack::Utils.status_code(:not_found),
        {
          "Content-Type" => "text/html; charset=utf-8",
          "Content-Length" => body.bytesize.to_s
        },
        [body]
      ]
    end

    def not_found_body
      not_found_page = Rails.root.join("public/404.html")
      return not_found_page.read if not_found_page.file?

      "Shop not found"
    end
  end
end
