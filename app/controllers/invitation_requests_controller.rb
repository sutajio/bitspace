class InvitationRequestsController < ApplicationController
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  before_filter :require_no_user
  
  def create
    @invitation_request = InvitationRequest.new(params[:invitation_request])
    @invitation_request.save
    flash[:notice] = 'Thanks you for your interest!'
    redirect_to root_path
  end
  
end
