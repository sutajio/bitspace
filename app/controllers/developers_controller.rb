class DevelopersController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def show
  end
  
  def branding
  end
  
  def upload
  end
  
  def library
  end
  
  def search
  end
  
  def account
  end
  
end
