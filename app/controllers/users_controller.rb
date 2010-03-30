class UsersController < ApplicationController
  layout 'site'
  
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def create
      @user = User.new(params[:user])
      @user.subscription_plan = User::SUBSCRIPTION_PLANS[:free][:name]
      @user.setup_subscription_plan_details
      @user.save!
      UserSession.create(@user)
      redirect_to player_path(:trailing_slash => true)
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.full_messages.to_sentence
    redirect_to signup_path
  end
  
  def unique
    if current_user
      current_user.attributes = params[:user]
      unless current_user.changed?
        render :json => true and return
      end
    end
    
    if User.find(:first, :conditions => params[:user]) ||
       User::DISALLOWED_USERNAMES.include?(params[:user][:login])
      render :json => false
    else
      render :json => true
    end
  end
  
end
