class InvitationsController < ApplicationController
  skip_before_filter :require_user
  before_filter :require_no_user
  
  def show
    if @invitation = Invitation.find_by_token(params[:id])
      @user = User.new(:email => @invitation.email)
    else
      flash[:warning] = "I'm sorry. This is not a valid invitation token."
      redirect_to(invitations_path) and return false
    end
  end
  
end
