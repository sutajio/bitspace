class DevicesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :require_user
  before_filter :find_user
  
  def create
    @user.devices.create(params[:device])
    head :ok
  end
  
end
