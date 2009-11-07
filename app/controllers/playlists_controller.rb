class PlaylistsController < ApplicationController
  
  def index
    @playlists = Playlist.find(:all)
    expires_in(30.seconds, :public => true)
  end
  
  def show
    @playlist = Playlist.find(params[:id])
    expires_in(30.seconds, :public => true)
  end
  
end
