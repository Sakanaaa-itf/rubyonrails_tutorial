class PasswordResetsController < ApplicationController
  before_action :set_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create
    @user = User.find_by(email: password_reset_params[:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if password_blank?
      handle_blank_password
    elsif @user.update(user_params)
      handle_successful_reset
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def password_reset_params
    params.require(:password_reset).permit(:email)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def password_blank?
    user_params[:password].blank?
  end

  def handle_blank_password
    @user.errors.add(:password, "can't be empty")
    render 'edit', status: :unprocessable_entity
  end

  def handle_successful_reset
    @user.update_column(:reset_digest, nil)
    log_in @user
    flash[:success] = 'Password has been reset.'
    redirect_to @user
  end

  def set_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    redirect_to(root_url) unless @user&.activated? && @user.authenticated?(:reset, params[:id])
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_url
  end
end
