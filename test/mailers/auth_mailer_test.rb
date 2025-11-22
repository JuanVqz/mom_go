require "test_helper"

class AuthMailerTest < ActionMailer::TestCase
  test "password reset email uses shop subdomain" do
    user = users(:tea_staff)
    token = user.issue_reset_password_token!

    email = AuthMailer.with(user:).password_reset

    assert_equal [user.email], email.to
    assert_includes email.body.encoded, "tea.example.com"
    assert_includes email.body.encoded, token
  end

  test "account locked email references reset link" do
    user = users(:tea_staff)
    token = user.issue_reset_password_token!

    email = AuthMailer.with(user:).account_locked

    assert_equal [user.email], email.to
    assert_includes email.subject, "locked"
    assert_includes email.body.encoded, token
  end
end
