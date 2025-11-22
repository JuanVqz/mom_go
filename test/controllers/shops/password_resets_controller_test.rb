require "test_helper"

module Shops
  class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper
    include ActionMailer::TestHelper

    setup do
      host! "tea.example.com"
      ActionMailer::Base.deliveries.clear
    end

    teardown { clear_enqueued_jobs }

    test "renders request form" do
      get new_shops_password_reset_path

      assert_response :success
      assert_select "h1", text: I18n.t("shops.password_resets.new.heading")
    end

    test "creates reset token and redirects" do
      post shops_password_reset_path, params: { password_reset_request_form: { email: "staff@tea.momgo.test" } }

      assert_redirected_to new_shops_session_path
      assert_enqueued_emails 1
    end

    test "rejects blank email" do
      post shops_password_reset_path, params: { password_reset_request_form: { email: "" } }

      assert_response :unprocessable_entity
      assert_select ".text-red-600", minimum: 1
    end

    test "renders reset form for valid token" do
      user = users(:tea_staff)
      token = user.issue_reset_password_token!

      get edit_shops_password_reset_path(token: token)

      assert_response :success
      assert_select "h1", text: I18n.t("shops.password_resets.edit.heading")
    end

    test "redirects for invalid token" do
      get edit_shops_password_reset_path(token: "bogus")

      assert_redirected_to new_shops_password_reset_path
      assert_equal I18n.t("auth.flash.password_resets.invalid_token"), flash[:alert]
    end

    test "updates password and signs in" do
      user = users(:tea_staff)
      token = user.issue_reset_password_token!

      patch shops_password_reset_path(token: token), params: {
        password_reset_form: { password: "new-password", password_confirmation: "new-password" }
      }

      assert_redirected_to shops_dashboard_path
      assert_equal user.reload.id, session[:user_id]
    end

    test "fails update for invalid token" do
      patch shops_password_reset_path(token: "bogus"), params: {
        password_reset_form: { password: "new-password", password_confirmation: "new-password" }
      }

      assert_response :unprocessable_entity
      assert_equal I18n.t("auth.flash.password_resets.invalid_token"), flash[:alert]
    end
  end
end
