class ArtistsController < ApplicationController
  
  def index
    @artists = Artist.search_for(params[:q]).paginate(:page => params[:page])
  end
  
  def show
    @artist = Artist.find(params[:id])
  end
  
end
