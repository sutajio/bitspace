class UsersController < ApplicationController
  
  skip_before_filter :require_user, :only => [:unique]
  
  def unique
    if current_user
      current_user.attributes = params[:user]
      unless current_user.changed?
        render :json => true and return
      end
    end
    
    if User.find(:first, :conditions => params[:user])
      render :json => false
    else
      render :json => true
    end
  end
  
end
