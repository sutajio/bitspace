class ProfilesController < ApplicationController
  
  skip_before_filter :require_user, :except => [:follow]
  before_filter :find_user
  
  layout 'application'
  
  def show
    unless request.request_uri =~ /\/$/
      redirect_to profile_path(@user.login, :trailing_slash => true)
    end
    @page_title = "Bitspace ◊ #{@user.login.anal_title_case}"
  end
  
  def follow
    if current_user.follows?(@user)
      current_user.unfollow!(@user)
    else
      current_user.follow!(@user)
    end
    if request.xhr?
      head :ok
    else
      redirect_to :back
    end
  end
  
  def subscribe
    @new_user = User.new unless current_user
    render :action => 'subscribe', :layout => 'site'
  end

end
