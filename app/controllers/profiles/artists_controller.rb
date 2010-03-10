class Profiles::ArtistsController < Profiles::ProfilesController

  def index
    @artists = @user.artists.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 20,
        :conditions => ['releases_count > 0'])
    if request.xhr? && @artists.empty?
      render :nothing => true
    end
  end
  
  def show
    @artist = @user.artists.find(params[:id])
    @page_title = @artist.name
  end

end
