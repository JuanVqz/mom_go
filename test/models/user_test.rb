require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers
  setup { Current.reset }
  teardown { Current.reset }

  test "requires name and email" do
    user = User.new(shop: shops(:tea), password: "credential123")

    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
    assert_includes user.errors[:email], "can't be blank"
  end

  test "normalizes and enforces unique email per shop" do
    shop = shops(:tea)
    user = User.new(shop:, name: " Another Staff ", email: " STAFF+manager@TEA.MOMGO.TEST ", password: "credential123")

    assert user.valid?
    assert_equal "Another Staff", user.name
    assert_equal "staff+manager@tea.momgo.test", user.email

    duplicate = User.new(shop:, name: "Duplicate", email: "staff@tea.momgo.test")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "scope respects Current.shop" do
    Current.shop = shops(:tea)
    assert_equal User.where(shop: shops(:tea)).ids.sort, User.all.ids.sort

    Current.shop = shops(:coffee)
    assert_equal User.where(shop: shops(:coffee)).ids.sort, User.all.ids.sort
  end

  test "requires password on create" do
    user = User.new(shop: shops(:tea), name: "Test", email: "test@tea.momgo.test")

    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end

  test "authenticates against password digest" do
    user = users(:tea_staff)

    assert user.authenticate("tea-credential")
    assert_not user.authenticate("wrong-credential")
  end

  test "lock helpers toggle state" do
    user = users(:tea_staff)

    refute user.locked?
    assert user.increment_failed_attempts!(threshold: 1)

    assert user.locked?

    user.unlock_account!
    refute user.locked?
    assert_equal 0, user.failed_attempts
  end

  test "issue_reset_password_token! stamps token and timestamp" do
    user = users(:tea_staff)
    freeze_time do
      token = user.issue_reset_password_token!

      assert token.present?
      assert_equal token, user.reload.reset_password_token
      assert_equal Time.current, user.reset_password_sent_at
    end
  end

  test "reset_password_token_expired? respects ttl" do
    user = users(:tea_staff)
    freeze_time do
      user.issue_reset_password_token!
      refute user.reset_password_token_expired?
    end

    travel Users::Credentials::RESET_TOKEN_TTL + 1.minute do
      assert user.reset_password_token_expired?
    end
  end

  test "register_successful_sign_in! clears lock and token" do
    user = users(:locked_staff)
    user.issue_reset_password_token!

    user.register_successful_sign_in!(ip: "127.0.0.1")

    assert_nil user.reload.locked_at
    assert_equal 0, user.failed_attempts
    assert_nil user.reset_password_token
    assert_nil user.reset_password_sent_at
    assert_equal "127.0.0.1", user.last_sign_in_ip
    assert_not_nil user.last_sign_in_at
  end
end
