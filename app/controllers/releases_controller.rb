class ReleasesController < ApplicationController
  
  before_filter :find_artist, :except => [:index]
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  def index
    @releases = current_user.releases.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 6,
        :include => [:artist],
        :order => 'created_at DESC',
        :conditions => ['artwork_file_size > ?', 32.kilobytes])
    if request.xhr? && @releases.empty?
      render :nothing => true
    end
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
      @artist = current_user.artists.find(params[:artist_id])
    end
  
end
