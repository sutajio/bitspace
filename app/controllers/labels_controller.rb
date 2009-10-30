class LabelsController < ApplicationController
  
  def index
    @labels = Label.search_for(params[:q]).paginate(:page => params[:page])
  end
  
  def show
    @label = Label.find(params[:id])
  end
  
end
