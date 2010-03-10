class Profiles::ReleasesController < Profiles::ProfilesController
  
  def index
    @releases = @user.releases.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 16,
        :include => [:artist],
        :order => 'created_at DESC',
        :conditions => { :archived => params[:q].present? ? [true,false] : false })
    if request.xhr? && @releases.empty?
      render :nothing => true
    end
  end
  
  def show
    @release = @user.releases.find(params[:id])
    @page_title = "#{@release.artist.name} – #{@release.title} (#{@release.year})"
  end
  
end
