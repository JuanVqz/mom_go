require "test_helper"
require "rack/mock"

class CurrentShopResolverMiddlewareTest < ActiveSupport::TestCase
  setup do
    @captured_shop = nil
    @app = lambda do |_env|
      @captured_shop = Current.shop
      [200, { "Content-Type" => "text/plain" }, ["OK"]]
    end

    @middleware = Middleware::CurrentShopResolverMiddleware.new(@app)
    Current.reset
  end

  teardown do
    Current.reset
  end

  test "assigns Current.shop for valid subdomain" do
    status, _, body = call_with_host("tea.example.com")

    assert_equal 200, status
    assert_equal ["OK"], body
    assert_equal shops(:tea), @captured_shop
    assert_nil Current.shop
  end

  test "returns 404 when subdomain missing" do
    status, _, body = call_with_host("example.com")

    assert_equal 404, status
    assert_nil @captured_shop
    assert_includes body.join, "The page you were looking for"
  end

  test "returns 404 when shop not found" do
    status, _, _body = call_with_host("ghost.example.com")

    assert_equal 404, status
    assert_nil @captured_shop
  end

  private

  def call_with_host(host)
    env = Rack::MockRequest.env_for("https://#{host}/orders", "HTTP_HOST" => host)
    @middleware.call(env)
  end
end
