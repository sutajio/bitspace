class DashboardsController < ApplicationController
  
  def show
    @latest = current_user.releases.has_tracks.all(
      :limit => 3,
      :order => 'created_at DESC',
      :conditions => { :archived => false })
  end
  
end
