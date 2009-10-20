class ImportsController < ApplicationController

  def create
    Track.import(
      :bucket => params[:bucket],
      :key => params[:key]
    )
    head :ok
  end

end
