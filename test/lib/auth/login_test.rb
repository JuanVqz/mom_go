require "test_helper"

module Auth
  class LoginTest < ActiveSupport::TestCase
    setup do
      @shop = shops(:tea)
      Current.reset
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
        assert_equal "Invalid email or password.", result.error
      end

      assert_equal 1, user.reload.failed_attempts
    end

    test "rejects locked users" do
      user = users(:locked_staff)

      result = Login.call(shop: @shop, params: { email: user.email, password: "locked-credential" })

      refute result.success?
      assert_equal "Account locked. Please reset your password or contact support.", result.error
    end

    test "fails when shop is missing" do
      result = Login.call(shop: nil, params: { email: "test@example.com", password: "secret" })

      refute result.success?
      assert_equal "Shop not found", result.error
    end
  end
end
