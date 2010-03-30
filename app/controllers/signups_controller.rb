class SignupsController < ApplicationController
  layout 'site'
  
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def show
    @user = User.new
  end
  
end
