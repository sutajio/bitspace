class ReleasesController < ApplicationController
  
  before_filter :find_artist, :except => [:index]
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  def index
    @releases = current_user.releases.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 8,
        :include => [:artist],
        :order => 'created_at DESC',
        :conditions => { :archived => params[:q].present? ? [true,false] : false })
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
  
  def archive
    @release = @artist.releases.find(params[:id])
    @release.toggle_archive!
    head :ok
  end
  
  def destroy
    @release = @artist.releases.find(params[:id])
    @release.destroy
    head :ok
  end
  
  protected
  
    def find_artist
      @artist = current_user.artists.find(params[:artist_id])
    end
  
end
