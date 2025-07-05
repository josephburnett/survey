class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:name])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      # Set longer session if "Remember Me" is checked
      if params[:remember_me] == "1"
        request.session_options[:expire_after] = 30.days
      end

      redirect_to root_path, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid name or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out successfully"
  end
end
