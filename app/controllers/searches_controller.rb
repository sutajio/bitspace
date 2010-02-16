class SearchesController < ApplicationController
  
  layout nil, :only => [:suggestions]
  
  rescue_from ScopedSearch::QueryNotSupported do |exception|
    head :no_content
  end
  
  rescue_from NoMethodError do |exception|
    head :no_content
  end
  
  def show
    @releases = current_user.releases.search_for(params[:q]).paginate(:page => params[:page], :include => [:artist, :tracks])
  end
  
  def suggestions
    @releases = current_user.releases.search_for(params[:q]).all(:limit => 5, :include => [:artist, :tracks])
  end
  
end
