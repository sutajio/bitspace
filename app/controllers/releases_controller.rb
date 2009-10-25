class ReleasesController < ApplicationController
  
  before_filter :find_artist
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  def index
    @releases = @artist.releases.search_for(params[:q]).paginate(:page => params[:page])
  end
  
  def show
    @release = @artist.releases.find(params[:id])
  end
  
  def edit
    @release = @artist.releases.find(params[:id])
  end
  
  def update
    @release = @artist.releases.find(params[:id])
    @release.update_attributes!(:artwork => params[:release][:artwork])
    head :ok
  rescue ActiveRecord::RecordInvalid => e
    raise e
  end
  
  protected
  
    def find_artist
      @artist = Artist.find(params[:artist_id])
    end
  
end
