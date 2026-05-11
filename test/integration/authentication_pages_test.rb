require "test_helper"

class AuthenticationPagesTest < ActionDispatch::IntegrationTest
  test "signin page" do
    get login_path
    assert_response :success
    assert_select "h1", "Log in"
    assert_select "title", "Log in | Ruby on Rails Tutorial Sample App"
  end
end
