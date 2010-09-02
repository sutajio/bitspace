class ArtistsController < ApplicationController
  
  skip_before_filter :require_user, :only => [:index, :show, :biography]
  before_filter :find_user, :only => [:index, :show, :biography]
  
  def index
    @artists = @user.artists.without_archived.has_releases.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 20)
    if request.xhr? && @artists.empty?
      render :nothing => true and return
    end
  end
  
  def show
    @artist = @user.artists.without_archived.has_releases.find(params[:id])
  end
  
  def biography
    @artist = @user.artists.without_archived.has_releases.find(params[:id])
    respond_to do |format|
      format.html
      format.txt
    end
  end
  
  def edit
    @artist = current_user.artists.without_archived.has_releases.find(params[:id])
  end
  
  def update
    @artist = current_user.artists.without_archived.has_releases.find(params[:id])
    @artist.biography = params[:artist][:biography]
    @artist.save!
    head :ok
  end
  
  def artwork
    @artist = current_user.artists.without_archived.has_releases.find(params[:id])
    if request.put?
      @artist.update_attributes!(:artwork => params[:artist][:artwork])
      head :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  end
  
end
