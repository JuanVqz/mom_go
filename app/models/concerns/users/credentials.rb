module Users
  module Credentials
    extend ActiveSupport::Concern

    DEFAULT_LOCK_THRESHOLD = 5

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
      with_lock do
        update!(failed_attempts: failed_attempts + 1)
        lock_account! if failed_attempts >= threshold && !locked?
      end
    end

    def register_successful_sign_in!(ip: nil)
      update!(last_sign_in_at: Time.current, last_sign_in_ip: ip, failed_attempts: 0, locked_at: nil)
    end

  end
end
