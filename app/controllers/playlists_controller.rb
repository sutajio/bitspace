class PlaylistsController < ApplicationController
  
  def index
    @playlists = Playlist.find(:all)
  end
  
  def show
    @playlist = Playlist.find(params[:id])
  end
  
end
