class PlaylistsController < ApplicationController
  
  def index
    @playlists = Playlist.find(:all)
    expires_in(5.minutes, :public => true)
  end
  
  def show
    @playlist = Playlist.find(params[:id])
    expires_in(5.minutes, :public => true)
  end
  
end
