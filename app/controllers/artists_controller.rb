class ArtistsController < ApplicationController
  
  skip_before_filter :require_user, :only => [:index, :show, :biography]
  before_filter :find_user, :only => [:index, :show, :biography]
  
  def index
    @artists = @user.artists.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 20,
        :conditions => ['releases_count > 0'])
    if request.xhr? && @artists.empty?
      render :nothing => true and return
    end
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def show
    @artist = @user.artists.with_releases.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def biography
    @artist = @user.artists.with_releases.find(params[:id])
  end
  
  def edit
    @artist = current_user.artists.with_releases.find(params[:id])
  end
  
  def update
    @artist = current_user.artists.with_releases.find(params[:id])
    @artist.biography = params[:artist][:biography]
    @artist.save!
    head :ok
  end
  
  def artwork
    @artist = current_user.artists.find(params[:id])
    if request.put?
      @artist.update_attributes!(:artwork => params[:artist][:artwork])
      head :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  end
  
  def playlist
    @artist = current_user.artists.with_releases.find(params[:id])
    respond_to do |format|
      format.json
    end
  end
  
end
