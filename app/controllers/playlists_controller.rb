class PlaylistsController < ApplicationController
  
  skip_before_filter :require_user, :only => [:index, :toplist, :recent, :latest]
  before_filter :find_user, :only => [:index, :toplist, :recent, :latest]
  
  def index
    @tracks = @user.tracks.loved.paginate(:page => params[:page], :per_page => 100, :order => 'loved_at DESC')
  end
  
  def toplist
    @tracks = @user.tracks.played_tracks.paginate(:page => params[:page], :per_page => 100, :order => 'scrobbles_count DESC')
  end
  
  def recent
    @tracks = @user.tracks.played_tracks.paginate(:page => params[:page], :per_page => 100, :order => 'scrobbled_at DESC')
  end
  
  def latest
    @tracks = @user.tracks.paginate(:page => params[:page], :per_page => 100, :order => 'created_at DESC')
  end
  
end
