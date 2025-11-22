require "test_helper"

module Auth
  class ResetPasswordTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::TimeHelpers

    setup do
      @shop = shops(:tea)
      @user = users(:locked_staff)
      Current.reset
      @token = @user.issue_reset_password_token!
    end

    test "updates password and unlocks account" do
      result = ResetPassword.call(shop: @shop, token: @token, params: { password: "new-secure-pass", password_confirmation: "new-secure-pass" })

      assert result.success?
      assert result.user.authenticate("new-secure-pass"), "expected password to change"
      refute result.user.locked?
      assert_nil result.user.reset_password_token
    end

    test "rejects invalid token" do
      result = ResetPassword.call(shop: @shop, token: "bad-token", params: { password: "new-secure-pass", password_confirmation: "new-secure-pass" })

      refute result.success?
      assert_equal I18n.t("auth.flash.password_resets.invalid_token"), result.error
    end

    test "rejects expired token" do
      travel_to (Users::Credentials::RESET_TOKEN_TTL + 5.minutes).from_now do
        result = ResetPassword.call(shop: @shop, token: @token, params: { password: "new-secure-pass", password_confirmation: "new-secure-pass" })

        refute result.success?
        assert_equal I18n.t("auth.flash.password_resets.invalid_token"), result.error
      end
    end

    test "validates password requirements" do
      result = ResetPassword.call(shop: @shop, token: @token, params: { password: "short", password_confirmation: "short" })

      refute result.success?
      assert_includes result.form.errors[:password], "is too short (minimum is 8 characters)"
    end
  end
end
