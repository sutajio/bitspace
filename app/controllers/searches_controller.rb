class SearchesController < ApplicationController
  
  def show
    @releases = Release.search_for(params[:q]).paginate(:page => params[:page], :include => [:artist, :tracks])
    expires_in(5.minutes, :public => true)
  end
  
end
