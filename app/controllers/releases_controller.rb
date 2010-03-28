class ReleasesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  def index
    @releases = current_user.releases.search_for(params[:q]).paginate(
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
    @release = current_user.releases.find(params[:id])
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
  
  def destroy
    @release = current_user.releases.find(params[:id])
    @release.destroy
    head :ok
  end
  
end
