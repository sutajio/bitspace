class InvitationsController < ApplicationController
  skip_before_filter :require_user
  before_filter :require_no_user
  before_filter :require_connected_user, :only => [:update]
  
  def show
    if @invitation = Invitation.find_by_token(params[:id])
      @user = User.find_by_email(@invitation.email) ||
              User.new(:email => @invitation.email)
      @user.subscription_plan = User::SUBSCRIPTION_PLANS[:beta][:name] if ENV['PRIVATE_BETA']
      @user.setup_subscription_plan_details
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def update
    if @invitation = Invitation.find_by_token(params[:id])
      @user = User.find_by_email(@invitation.email) ||
              User.new(:email => @invitation.email)
      @user.subscription_plan = User::SUBSCRIPTION_PLANS[:beta][:name] if ENV['PRIVATE_BETA']
      @user.setup_subscription_plan_details
      @user.facebook_uid = facebook_session.user.id
      @user.save!
      @invitation.destroy
      UserSession.create(@user)
      redirect_to root_path
    else
      raise ActiveRecord::RecordNotFound
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.full_messages.to_sentence
    redirect_to :action => 'show'
  end
  
end
