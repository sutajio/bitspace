class ArtistsController < ApplicationController
  
  def index
    @artists = current_user.artists.search_for(params[:q]).paginate(
        :page => params[:page],
        :include => [:releases],
        :conditions => ['releases_count > 0'])
    expires_in(30.seconds, :public => true)
    if request.xhr? && @artists.empty?
      render :nothing => true
    end
  end
  
  def show
    @artist = current_user.artists.find(params[:id])
    expires_in(30.seconds, :public => true)
  end
  
end
