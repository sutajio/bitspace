class Profiles::ProfilesController < ApplicationController
  
  skip_before_filter :require_user, :except => [:follow]
  before_filter :find_user
  layout 'profile'
  
  def show
    @releases = @user.releases.has_tracks.all(
      :limit => 3,
      :order => 'created_at DESC',
      :conditions => { :archived => false })
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
  end
  
  protected
  
    def find_user
      @user = User.find_by_login_and_public_profile(params[:profile_id] || params[:id], true)
      raise ActiveRecord::RecordNotFound unless @user
    end

end
