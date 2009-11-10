class SearchesController < ApplicationController
  
  def show
    @releases = current_user.releases.search_for(params[:q]).paginate(:page => params[:page], :include => [:artist, :tracks])
  end
  
end
