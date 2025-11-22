require "test_helper"

module Auth
  class LoginTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper
    include ActionMailer::TestHelper
    setup do
      @shop = shops(:tea)
      Current.reset
      ActionMailer::Base.deliveries.clear
      Auth::Metrics.reset_failed_login!(shop: @shop)
    end

    teardown do
      clear_enqueued_jobs
    end

    test "returns user when credentials valid" do
      result = Login.call(shop: @shop, params: { email: "STAFF@tea.momgo.test", password: "tea-credential" }, ip: "127.0.0.1")

      assert result.success?, "expected login to succeed"
      assert_equal users(:tea_staff), result.user
    end

    test "fails and increments attempts for wrong password" do
      user = users(:tea_staff)

      assert_no_difference -> { User.count } do
        result = Login.call(shop: @shop, params: { email: user.email, password: "wrong-credential" })

        refute result.success?
        assert_equal I18n.t("auth.errors.invalid_credentials"), result.error
      end

      assert_equal 1, user.reload.failed_attempts
    end

    test "rejects locked users" do
      user = users(:locked_staff)

      result = Login.call(shop: @shop, params: { email: user.email, password: "locked-credential" })

      refute result.success?
      assert_equal I18n.t("auth.errors.locked"), result.error
    end

    test "locks account after threshold and emails user" do
      user = users(:tea_staff)

      assert_enqueued_emails 0

      (Users::Credentials::DEFAULT_LOCK_THRESHOLD).times do
        result = Login.call(shop: @shop, params: { email: user.email, password: "wrong" })
        refute result.success?
      end

      assert user.reload.locked?
      assert_enqueued_emails 1
      perform_enqueued_jobs

      mail = ActionMailer::Base.deliveries.last
      expected_subject = I18n.t("auth_mailer.account_locked.subject", brand: I18n.t("auth.brand_name"))
      assert_equal expected_subject, mail.subject
    end

    test "fails when shop is missing" do
      result = Login.call(shop: nil, params: { email: "test@example.com", password: "secret" })

      refute result.success?
      assert_equal I18n.t("auth.errors.shop_missing"), result.error
    end

    test "increments failed login metric" do
      Login.call(shop: @shop, params: { email: "staff@tea.momgo.test", password: "wrong" })

      assert_equal 1, Auth::Metrics.failed_login_count(shop: @shop)
    end

    test "instruments login events" do
      payloads = capture_notifications("auth.login") do
        Login.call(shop: @shop, params: { email: "STAFF@tea.momgo.test", password: "tea-credential" }, ip: "127.0.0.1")
      end

      assert_includes payloads.map { |data| data[:status] }, :success
      assert_equal @shop.id, payloads.last[:shop_id]

      failure_payloads = capture_notifications("auth.login") do
        Login.call(shop: @shop, params: { email: "staff@tea.momgo.test", password: "wrong" }, ip: "127.0.0.1")
      end

      failure = failure_payloads.detect { |data| data[:status] != :success }
      assert_equal :failure, failure[:status]
      assert_equal :invalid_credentials, failure.dig(:metadata, :reason)
    end

    def capture_notifications(event)
      payloads = []
      subscriber = ActiveSupport::Notifications.subscribe(event) { |*args| payloads << args.last }
      yield
      payloads
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    end
  end
end
