class DashboardsController < ApplicationController
  
  skip_before_filter :require_user
  before_filter :find_user
  
  def show
    @latest = @user.releases.has_tracks.all(
      :limit => 3,
      :order => 'created_at DESC',
      :conditions => { :archived => false })
  end
  
end
