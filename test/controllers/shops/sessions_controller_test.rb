require "test_helper"

module Shops
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      host! "tea.example.com"
    end

    test "renders login form" do
      get new_shops_session_path

      assert_response :success
      expected = I18n.t("shops.sessions.new.heading", shop_name: shops(:tea).name)
      assert_select "h1", text: expected
    end

    test "returns 404 when shop is missing" do
      host! "ghost.example.com"

      get new_shops_session_path

      assert_response :not_found
      assert_match I18n.t("auth.errors.shop_missing"), @response.body
    end

    test "rejects blank submission" do
      post shops_session_path, params: { session_form: { email: "", password: "" } }

      assert_response :unprocessable_entity
      assert_select ".text-red-600", minimum: 1
    end

    test "signs in valid user" do
      post shops_session_path, params: { session_form: { email: "staff@tea.momgo.test", password: "tea-credential" } }

      assert_redirected_to shops_dashboard_path
      assert_equal users(:tea_staff).id, session[:user_id]
    end

    test "signs out" do
      post shops_session_path, params: { session_form: { email: "staff@tea.momgo.test", password: "tea-credential" } }
      delete shops_session_path

      assert_redirected_to new_shops_session_path
      assert_nil session[:user_id]
    end
  end
end
