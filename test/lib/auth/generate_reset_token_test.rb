require "test_helper"

module Auth
  class GenerateResetTokenTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper
    include ActionMailer::TestHelper

    setup do
      @shop = shops(:tea)
      Current.reset
      ActionMailer::Base.deliveries.clear
    end

    teardown { clear_enqueued_jobs }

    test "issues token and emails instructions" do
      user = users(:tea_staff)

      result = GenerateResetToken.call(shop: @shop, params: { email: user.email })

      assert result.success?
      assert user.reload.reset_password_token.present?
      assert_enqueued_emails 1
    end

    test "requires email" do
      result = GenerateResetToken.call(shop: @shop, params: { email: "" })

      refute result.success?
      assert_equal I18n.t("auth.errors.request_email_missing"), result.error
    end

    test "is successful even when email does not exist" do
      result = GenerateResetToken.call(shop: @shop, params: { email: "unknown@example.com" })

      assert result.success?
      assert_enqueued_emails 0
    end
  end
end
