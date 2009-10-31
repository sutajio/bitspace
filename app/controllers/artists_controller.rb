class ArtistsController < ApplicationController
  
  def index
    @artists = Artist.search_for(params[:q]).paginate(
        :page => params[:page],
        :include => [:releases],
        :conditions => ['releases_count > 0'])
    expires_in(5.minutes, :public => true)
    if request.xhr? && @artists.empty?
      head :not_found
    end
  end
  
  def show
    @artist = Artist.find(params[:id])
    expires_in(5.minutes, :public => true)
    fresh_when(:last_modified => @artist.updated_at.utc, :public => true)
  end
  
end
