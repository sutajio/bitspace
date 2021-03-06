class InvitationsController < ApplicationController
  layout 'site'
  
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def show
    if @invitation = Invitation.find_by_token(params[:id])
      @user = User.new(:email => @invitation.email)
      @user.subscription_plan = @invitation.subscription_plan if @invitation.subscription_plan.present?
      @user.setup_subscription_plan_details
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def update
    if @invitation = Invitation.find_by_token(params[:id])
      @user = User.new(params[:user])
      if @invitation.first_name.present? || @invitation.last_name.present?
        @user.name = [@invitation.first_name, @invitation.last_name].compact.join(' ')
      end
      @user.subscription_id = @invitation.subscription_id
      @user.subscription_plan = @invitation.subscription_plan if @invitation.subscription_plan.present?
      @user.setup_subscription_plan_details
      @user.save!
      InvitationRequest.destroy_all(["email = ?", @invitation.email])
      @invitation.destroy
      UserSession.create(@user)
      redirect_to player_path(:trailing_slash => true)
    else
      raise ActiveRecord::RecordNotFound
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.record.errors.full_messages.to_sentence
    redirect_to :action => 'show'
  end
  
end
