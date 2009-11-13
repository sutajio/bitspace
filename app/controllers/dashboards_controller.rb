class DashboardsController < ApplicationController
  
  def show
    @latest = current_user.releases.all(
      :limit => 3,
      :order => 'created_at DESC',
      :conditions => ['artwork_file_size > ?', 32.kilobytes])
  end
  
end
