class LabelsController < ApplicationController
  
  def index
    @labels = current_user.labels.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 10)
    if request.xhr? && @labels.empty?
      render :nothing => true
    end
  end
  
  def show
    @label = current_user.labels.find(params[:id])
  end
  
end
