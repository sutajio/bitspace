class SearchesController < ApplicationController
  
  def show
    @releases = Release.search_for(params[:q]).paginate(:page => params[:page], :include => [:artist, :tracks])
  end
  
end
