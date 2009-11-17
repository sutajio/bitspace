class PagesController < ApplicationController
  
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def index
  end
  
  def price
  end
  
  def tour
  end
  
  def about
  end
  
end
