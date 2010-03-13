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
        params[:release][:tracks].each do |id,attributes|
          track = @release.tracks.find_by_id(id)
          track.title = attributes[:title]
          track.save!
        end
      end
      if params[:release][:title]
        other_release = @release.artist.releases.find_by_title(params[:release][:title])
        if other_release && other_release != @release
          other_release.merge!(@release)
          @release = other_release
        else
          @release.update_attributes!(:title => params[:release][:title])
        end
      end
      if params[:release][:artist] && params[:release][:artist][:name]
        artist = current_user.artists.find_or_create_by_name(params[:release][:artist][:name])
        other_release = artist.releases.find_by_title(@release.title)
        if other_release && other_release != @release
          other_release.merge!(@release)
          @release = other_release
        else
          old_artist = @release.artist
          @release.artist = artist
          @release.save!
          old_artist.touch
          artist.touch
        end
      end
      if params[:release][:year]
        @release.year = params[:release][:year].to_i == 0 ? nil : params[:release][:year].to_i
        @release.save!
      end
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
