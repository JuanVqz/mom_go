require "test_helper"

class PasswordResetFlowTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    host! "tea.example.com"
    ActionMailer::Base.deliveries.clear
  end

  teardown { clear_enqueued_jobs }

  test "shop staff can reset password end-to-end" do
    user = users(:tea_staff)
    new_password = "super-secure-password"

    assert_enqueued_emails 1 do
      post shops_password_reset_path, params: { password_reset_request_form: { email: user.email } }
    end

    token = user.reload.reset_password_token
    assert_not_nil token, "expected reset token to be persisted"

    get edit_shops_password_reset_path(token: token)
    assert_response :success

    patch shops_password_reset_path(token: token), params: {
      password_reset_form: { password: new_password, password_confirmation: new_password }
    }

    assert_redirected_to shops_dashboard_path
    assert_nil user.reload.reset_password_token, "expected reset token to be cleared"

    delete shops_session_path
    assert_redirected_to new_shops_session_path

    post shops_session_path, params: { session_form: { email: user.email, password: new_password } }

    assert_redirected_to shops_dashboard_path
    assert user.reload.authenticate(new_password)
  end
end
