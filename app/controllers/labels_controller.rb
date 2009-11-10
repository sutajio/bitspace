class LabelsController < ApplicationController
  
  def index
    @labels = current_user.labels.search_for(params[:q]).paginate(:page => params[:page])
  end
  
  def show
    @label = current_user.labels.find(params[:id])
  end
  
end
