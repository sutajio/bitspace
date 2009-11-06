class TracksController < ApplicationController
  
  def love
    @track = current_user.tracks.find(params[:id])
    @track.toggle_love!
    head :ok
  end
  
end
