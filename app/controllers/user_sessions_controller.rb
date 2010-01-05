class UserSessionsController < ApplicationController
  
  skip_before_filter :require_user
  before_filter :require_no_user, :only => [:new, :create]
  layout 'login'
  
  def new
  end
  
  def create
    @user_session = UserSession.create(:login => params[:login],
                                       :password => params[:password],
                                       :remember_me => true)
    if @user_session.valid?
      redirect_to player_path(:trailing_slash => true)
    else
      flash[:error] = @user_session.errors.full_messages.to_sentence
      redirect_to login_path
    end
  end
  
  def destroy
    current_user_session.destroy if current_user_session
    redirect_to login_path
  end
  
end