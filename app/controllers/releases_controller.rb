class ReleasesController < ApplicationController
  
  before_filter :find_artist
  
  def index
    @releases = @artist.releases.search_for(params[:q]).paginate(:page => params[:page])
  end
  
  protected
  
    def find_artist
      @artist = Artist.find(params[:artist_id])
    end
  
end
