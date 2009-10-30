class ArtistsController < ApplicationController
  
  def index
    @artists = Artist.search_for(params[:q]).paginate(:page => params[:page])
    expires_in(60.seconds, :public => true)
    if request.xhr? && @artists.empty?
      head :not_found
    end
  end
  
  def show
    @artist = Artist.find(params[:id])
    fresh_when(:last_modified => @artist.updated_at.utc, :public => true)
  end
  
end
