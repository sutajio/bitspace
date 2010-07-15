class SearchesController < ApplicationController
  
  skip_before_filter :require_user, :only => [:show, :suggestions]
  before_filter :find_user, :only => [:show, :suggestions]
  
  layout nil, :only => [:suggestions]
  
  rescue_from ScopedSearch::QueryNotSupported do |exception|
    head :no_content
  end
  
  rescue_from NoMethodError do |exception|
    head :no_content
  end
  
  def show
    @releases = @user.releases.without_archived.search_for(params[:q]).paginate(:page => params[:page], :include => [:artist, :tracks])
  end
  
  def suggestions
    @releases = @user.releases.without_archived.search_for(params[:q]).all(:limit => 5, :include => [:artist, :tracks])
  end
  
end
