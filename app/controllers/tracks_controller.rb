class TracksController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  def love
    @track = current_user.tracks.find(params[:id])
    if params[:toggle] == 'on'
      @track.love!
    elsif params[:toggle] == 'off'
      @track.unlove!
    else
      @track.toggle_love!
    end
    @track.release.touch
    head :ok
  end
  
  def now_playing
    @track = current_user.tracks.find(params[:id])
    Scrobble.now_playing(@track, current_user)
    head :ok
  end
  
  def scrobble
    @track = current_user.tracks.find(params[:id])
    @track.scrobble!(params[:started_playing] ? 
                          Time.parse(params[:started_playing]) :
                          Time.now.utc,
                     request.remote_ip)
    head :ok
  end
  
  def destroy
    @track = current_user.tracks.find(params[:id])
    Track.transaction do
      @track.release.touch
      @track.destroy
    end
    head :ok
  end
  
end
