class LabelsController < ApplicationController
  
  def index
    @labels = current_user.labels.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 20,
        :order => 'releases_count DESC',
        :conditions => ['releases_count > 0'])
    if request.xhr? && @labels.empty?
      render :nothing => true
    end
  end
  
  def show
    @label = current_user.labels.find(params[:id])
  end
  
end
