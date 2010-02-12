class SearchesController < ApplicationController
  
  layout nil, :only => [:suggestions]
  
  def show
    @releases = current_user.releases.search_for(params[:q]).paginate(:page => params[:page], :include => [:artist, :tracks])
  end
  
  def suggestions
    @releases = current_user.releases.search_for(params[:q]).all(:limit => 5, :include => [:artist, :tracks])
  end
  
end
