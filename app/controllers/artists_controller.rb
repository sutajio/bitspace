class ArtistsController < ApplicationController
  
  def index
    @artists = Artist.search_for(params[:q]).paginate(:page => params[:page])
    if request.xhr? && @artists.empty?
      head :not_found
    end
  end
  
  def show
    @artist = Artist.find(params[:id])
  end
  
end
