require "test_helper"

class AuthRateLimitingTest < ActionDispatch::IntegrationTest
  setup do
    host! "tea.example.com"
    Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
  end

  test "throttles repeated login attempts and instruments rate limit" do
    limit = Rails.configuration.x.auth.login_rate_limit
    (limit).times do
      post shops_session_path, params: { session_form: { email: "staff@tea.momgo.test", password: "wrong" } }
      assert_response :unprocessable_entity
    end

    payloads = []
    subscriber = ActiveSupport::Notifications.subscribe("auth.rate_limit") { |*args| payloads << args.last }

    post shops_session_path, params: { session_form: { email: "staff@tea.momgo.test", password: "wrong" } }

    assert_response :too_many_requests
    assert_includes @response.body, I18n.t("auth.flash.rate_limit")
    assert payloads.any? { |data| data[:path] == "/session" }
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end
end
