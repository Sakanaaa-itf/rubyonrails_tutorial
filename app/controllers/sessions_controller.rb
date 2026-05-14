class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: session_params[:email].downcase)
    if user&.authenticate(session_params[:password])
      handle_authenticated_user(user)
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def handle_authenticated_user(user)
    if user.activated?
      handle_successful_login(user)
    else
      flash[:warning] = 'Account not activated. Check your email for the activation link.'
      redirect_to root_url
    end
  end

  def handle_successful_login(user)
    log_in user
    session_params[:remember_me] == '1' ? remember(user) : forget(user)
    redirect_back_or user
  end

  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end
end
