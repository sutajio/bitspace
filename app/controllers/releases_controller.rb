class ReleasesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  skip_before_filter :require_user, :only => [:index, :show, :download, :popular, :newest]
  before_filter :find_user, :only => [:index, :show, :download]
  
  layout 'share', :only => [:download]
  
  def index
    respond_to do |format|
      format.html do
        order = case params[:order]
        when 'title': 'title ASC'
        when 'artist': 'artists.name ASC'
        when 'tracks_count': 'tracks_count DESC'
        else
          'created_at DESC'
        end
        @releases = @user.releases.without_archived.has_tracks.paginate(
          :page => params[:page],
          :per_page => 16,
          :include => [:artist],
          :order => order)
        if request.xhr? && @releases.empty?
          render :nothing => true and return
        end
      end
      format.json do
        @releases = @user.releases.updated_since(params[:since]).with_archived.paginate(
            :page => params[:page],
            :per_page => 10,
            :include => [:artist, :label, :tracks],
            :order => 'created_at')
      end
    end
  end

  def inbox
    respond_to do |format|
      format.json do
        @releases = @user.releases.updated_since(params[:since]).with_archived.paginate(
          :page => params[:page],
          :per_page => 10,
          :include => [:artist, :label, :tracks],
          :order => 'created_at DESC'
        )
        render :json => {
          :page => @releases.current_page,
          :pages => @releases.total_pages,
          :per_page => @releases.per_page,
          :total => @releases.total_entries,
          :releases => @releases.map {|release|
            release_to_hash(release, :simple => false)
          }
        }
      end
    end
  end

  def popular
    respond_to do |format|
      format.json do
        @releases = Release.updated_since(params[:since]).with_archived.paginate(
          :page => params[:page],
          :per_page => 10,
          :include => [:artist, :label, :tracks],
          :order => 'popularity DESC'
        )
        render :json => {
          :page => @releases.current_page,
          :pages => @releases.total_pages,
          :per_page => @releases.per_page,
          :total => @releases.total_entries,
          :releases => @releases.map {|release|
            release_to_hash(release, :simple => false)
          }
        }
      end
    end
  end

  def newest
    respond_to do |format|
      format.json do
        @releases = Release.updated_since(params[:since]).with_archived.paginate(
          :page => params[:page],
          :per_page => 10,
          :include => [:artist, :label, :tracks],
          :order => 'created_at DESC'
        )
        render :json => {
          :page => @releases.current_page,
          :pages => @releases.total_pages,
          :per_page => @releases.per_page,
          :total => @releases.total_entries,
          :releases => @releases.map {|release|
            release_to_hash(release, :simple => false)
          }
        }
      end
    end
  end

  def show
    @release = Release.without_archived.has_tracks.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
    @release = current_user.releases.without_archived.has_tracks.find(params[:id])
  end
  
  def update
    @release = current_user.releases.without_archived.has_tracks.find(params[:id])
    @release.transaction do
      if params[:release][:tracks]
        @release.rename_tracks(params[:release][:tracks])
      end
      if params[:release][:title]
        @release = @release.rename(params[:release][:title])
      end
      if params[:release][:artist] && params[:release][:artist][:name]
        @release = @release.rename_artist(params[:release][:artist][:name])
      end
      if params[:release][:year]
        @release.change_year(params[:release][:year])
      end
      @release.tracks.each(&:touch)
    end
    @release.touch
    if request.xhr?
      render :text => release_path(@release)
    else
      redirect_to release_path(@release)
    end
  end
  
  def artwork
    @release = current_user.releases.without_archived.has_tracks.find(params[:id])
    if request.put?
      @release.update_attributes!(:artwork => params[:release][:artwork])
      @release.tracks.each(&:touch)
      head :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  end
  
  def download
    @release = Release.without_archived.has_tracks.find(params[:id])
    head :forbidden and return unless @release.playable?(current_user)
    if request.xhr?
      render :text => @release.download_url
    else
      if @release.download_url
        redirect_to @release.download_url
      else
        @release.generate_download
      end
    end
  end
  
  def sideload
    @release = Release.without_archived.has_tracks.find(params[:id])
    head :forbidden and return unless @release.playable?(current_user)
    @release.sideload(current_user)
    head :ok
  end
  
  def destroy
    @release = current_user.releases.without_archived.has_tracks.find(params[:id])
    Release.transaction do
      @release.tracks.each(&:destroy)
      @release.archive!
    end
    head :ok
  end

end
