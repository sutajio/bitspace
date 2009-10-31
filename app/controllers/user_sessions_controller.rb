class UserSessionsController < ApplicationController
  skip_before_filter :require_user
  
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to root_path
    else
      render :text => 'Login failed, invalid username or password.', :status => :forbidden
    end
  end

  def destroy
    current_user_session.destroy if current_user_session
    redirect_to root_path
  end
  
end