class ArtistsController < ApplicationController
  
  def index
    @artists = current_user.artists.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 20,
        :conditions => ['releases_count > 0'])
    if request.xhr? && @artists.empty?
      render :nothing => true
    end
  end
  
  def show
    @artist = current_user.artists.with_releases.find(params[:id])
  end
  
  def biography
    @artist = current_user.artists.with_releases.find(params[:id])
  end
  
end
