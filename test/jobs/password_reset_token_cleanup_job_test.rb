require "test_helper"

class PasswordResetTokenCleanupJobTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  test "removes expired reset tokens" do
    user = users(:tea_staff)
    user.update!(reset_password_token: "token", reset_password_sent_at: 2.hours.ago)

    PasswordResetTokenCleanupJob.perform_now

    user.reload
    assert_nil user.reset_password_token
    assert_nil user.reset_password_sent_at
  end
end
