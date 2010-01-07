class UsersController < ApplicationController
  
  skip_before_filter :require_user, :only => [:unique]
  
  def unique
    if User.find(:first, :conditions => params[:user])
      render :json => false
    else
      render :json => true
    end
  end
  
end
