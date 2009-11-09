class PagesController < ApplicationController
  
  skip_before_filter :require_user
  
  def index
  end
  
  def price
  end
  
  def tour
  end
  
  def help
  end
  
end
