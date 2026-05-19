require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test 'password resets' do
    get new_password_reset_path
    assert_template 'password_resets/new'

    post password_resets_path, params: { password_reset: { email: '' } }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    user = request_password_reset
    assert_blank_email_rejected(user)
    assert_inactive_user_rejected(user)
    assert_wrong_token_rejected(user)
    assert_reset_edit_page(user)
    assert_invalid_password_updates(user)
    assert_valid_password_update(user)
  end

  test 'expired token' do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }
    user = assigns(:user)
    user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'foobaz' } }
    assert_response :redirect
    follow_redirect!
    assert_match(/expired/i, response.body)
  end

  private

  def request_password_reset
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    assigns(:user)
  end

  def assert_blank_email_rejected(user)
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url
  end

  def assert_inactive_user_rejected(user)
    user.update_attribute(:activated, false)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.update_attribute(:activated, true)
  end

  def assert_wrong_token_rejected(user)
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
  end

  def assert_reset_edit_page(user)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', user.email
  end

  def assert_invalid_password_updates(user)
    patch_password_reset(user, '', '')
    assert_select 'div#error_explanation'

    patch_password_reset(user, 'foobaz', 'barquux')
    assert_select 'div#error_explanation'
  end

  def assert_valid_password_update(user)
    patch_password_reset(user, 'foobaz', 'foobaz')
    assert logged_in?
    assert_not flash.empty?
    assert_redirected_to user
    assert_nil user.reload.reset_digest
  end

  def patch_password_reset(user, password, confirmation)
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password: password,
                            password_confirmation: confirmation } }
  end
end
