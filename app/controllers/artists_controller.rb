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
  
end
