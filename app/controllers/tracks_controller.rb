class TracksController < ApplicationController
  
  def love
    @track = Track.find(params[:id])
    @track.toggle_love!
    head :ok
  end
  
end
