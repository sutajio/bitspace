class LabelsController < ApplicationController
  
  skip_before_filter :require_user, :only => [:index, :show]
  before_filter :find_user, :only => [:index, :show]
  
  def index
    @labels = @user.labels.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 20,
        :order => 'releases_count DESC',
        :conditions => ['releases_count > 0'])
    if request.xhr? && @labels.empty?
      render :nothing => true and return
    end
  end
  
  def show
    @label = @user.labels.find(params[:id])
  end
  
end
