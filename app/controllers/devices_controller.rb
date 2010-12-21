class DevicesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :require_user
  before_filter :find_user
  before_filter :filter_invalid_base64
  
  def create
    @device = @user.devices.create(params[:device])
    head :ok
  end
  
  protected
  
    def filter_invalid_base64
      if params[:device][:apns_token]
        params[:device][:apns_token].gsub!(' ','+')
      end
    end
  
end
