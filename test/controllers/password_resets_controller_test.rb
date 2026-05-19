require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get new_password_reset_url
    assert_response :success
  end

  test 'should redirect invalid edit' do
    get edit_password_reset_url('invalid', email: '')
    assert_redirected_to root_url
  end
end
