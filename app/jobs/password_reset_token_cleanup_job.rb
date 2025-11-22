class PasswordResetTokenCleanupJob < ApplicationJob
  queue_as :default

  def perform
    cutoff = Users::Credentials::RESET_TOKEN_TTL.ago

    User.without_tenant_scope do
      User.where.not(reset_password_token: nil)
          .where("reset_password_sent_at < ?", cutoff)
          .in_batches(of: 500) do |relation|
        relation.update_all(reset_password_token: nil, reset_password_sent_at: nil, updated_at: Time.current)
      end
    end
  end
end
