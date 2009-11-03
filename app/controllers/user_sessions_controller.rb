class UserSessionsController < ApplicationController
  skip_before_filter :require_user
  before_filter :require_no_user, :except => [:destroy]
  before_filter :require_connected_user, :only => [:create]
  
  def new
  end
  
  def create
    user = User.find_or_create_by_facebook_uid(
      :facebook_uid => facebook_session.user.uid,
      :email => "#{facebook_session.user.id}@facebook.com",
      :login => Rails.env.production? ? facebook_session.user.name : facebook_session.user.id,
      :password => '123456')
    @user_session = UserSession.create(user)
    if @user_session.save
      redirect_to root_path
    else
      render :text => @user_session.errors.full_messages.to_sentence, :status => :forbidden
    end
  end

  def destroy
    current_user_session.destroy if current_user_session
    redirect_to root_path
  end
  
end