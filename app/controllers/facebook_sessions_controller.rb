class FacebookSessionsController < ApplicationController
  skip_before_filter :require_user
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_connected_user, :only => [:create]
  
  def new
  end
  
  def create
    @user = User.find_by_facebook_uid(facebook_session_user_uid) or raise ActiveRecord::RecordNotFound
    if @user_session = UserSession.create(@user)
      redirect_to player_path(:trailing_slash => true)
    else
      flash[:error] = @user_session.errors.full_messages.to_sentence
      redirect_to root_path
    end
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = 'Sorry, Bitspace is currently invitation only.'
    redirect_to root_path
  end

  def destroy
    clear_facebook_session_information
    clear_fb_cookies!
    current_user_session.destroy if current_user_session
    redirect_to root_path
  end
  
  protected
  
    def facebook_session_user_uid
      facebook_session.user.uid
    end

end
