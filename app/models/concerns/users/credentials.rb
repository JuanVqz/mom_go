module Users
  module Credentials
    extend ActiveSupport::Concern

    DEFAULT_LOCK_THRESHOLD = 5
    RESET_TOKEN_TTL = 30.minutes

    included do
      has_secure_password

      normalizes :reset_password_token, with: ->(token) { token.to_s.presence }

      validates :password, length: { minimum: 8 }, allow_nil: true
      validates :failed_attempts, numericality: { greater_than_or_equal_to: 0 }

      scope :locked, -> { where.not(locked_at: nil) }
    end

    def locked?
      locked_at.present?
    end

    def lock_account!
      update!(locked_at: Time.current)
    end

    def unlock_account!
      update!(locked_at: nil, failed_attempts: 0)
    end

    def increment_failed_attempts!(threshold: DEFAULT_LOCK_THRESHOLD)
      newly_locked = false

      with_lock do
        new_attempts = failed_attempts + 1
        attrs = { failed_attempts: new_attempts }
        if locked_at.nil? && new_attempts >= threshold
          attrs[:locked_at] = Time.current
          newly_locked = true
        end
        update!(attrs)
      end

      newly_locked
    end

    def register_successful_sign_in!(ip: nil)
      update!(
        last_sign_in_at: Time.current,
        last_sign_in_ip: ip,
        failed_attempts: 0,
        locked_at: nil,
        reset_password_token: nil,
        reset_password_sent_at: nil
      )
    end

    def issue_reset_password_token!
      with_lock do
        update!(reset_password_token: generate_unique_reset_token, reset_password_sent_at: Time.current)
      end
      reset_password_token
    end

    def clear_reset_password_token!
      update!(reset_password_token: nil, reset_password_sent_at: nil)
    end

    def reset_password_token_expired?
      reset_password_sent_at.blank? || reset_password_sent_at < RESET_TOKEN_TTL.ago
    end

    private

    def generate_unique_reset_token
      loop do
        token = SecureRandom.urlsafe_base64(32)
        break token unless self.class.without_tenant_scope.exists?(reset_password_token: token)
      end
    end
  end
end
