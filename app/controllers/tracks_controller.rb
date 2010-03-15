class TracksController < ApplicationController
  
  def love
    @track = current_user.tracks.find(params[:id])
    @track.toggle_love!
    head :ok
  end
  
  def now_playing
    @track = current_user.tracks.find(params[:id])
    Scrobble.now_playing(@track, current_user)
    head :ok
  end
  
  def scrobble
    @track = current_user.tracks.find(params[:id])
    @scrobble = @track.scrobbles.create!(
        :user_id => current_user.id,
        :ip => request.remote_ip,
        :started_playing => params[:started_playing] ? 
                              Time.parse(params[:started_playing]) :
                              Time.now.utc)
    Delayed::Job.enqueue(@scrobble)
    head :ok
  end
  
  def destroy
    @track = current_user.tracks.find(params[:id])
    @track.destroy
    head :ok
  end
  
end
