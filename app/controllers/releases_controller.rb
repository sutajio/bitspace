class ReleasesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  skip_before_filter :require_user, :only => [:index, :show, :download]
  before_filter :find_user, :only => [:index, :show, :download]
  
  layout 'site', :only => [:download]
  
  def index
    respond_to do |format|
      format.html do
        @releases = @user.releases.without_archived.has_tracks.paginate(
            :page => params[:page],
            :per_page => 16,
            :include => [:artist],
            :order => 'created_at DESC')
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
  
  def show
    @release = @user.releases.find(params[:id])
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
    @release = current_user.releases.find(params[:id])
  end
  
  def update
    @release = current_user.releases.find(params[:id])
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
    @release = current_user.releases.find(params[:id])
    if request.put?
      @release.update_attributes!(:artwork => params[:release][:artwork])
      @release.tracks.each(&:touch)
      head :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  end
  
  def archive
    @release = current_user.releases.find(params[:id])
    @release.toggle_archive!
    head :ok
  end
  
  def download
    @release = Release.find(params[:id])
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
    @release = Release.find(params[:id])
    head :forbidden and return unless @release.playable?(current_user)
    @release.sideload(current_user)
    head :ok
  end
  
  def destroy
    @release = current_user.releases.find(params[:id])
    Release.transaction do
      @release.tracks.each(&:destroy)
      @release.archive!
    end
    head :ok
  end

end
