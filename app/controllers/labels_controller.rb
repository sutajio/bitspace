class LabelsController < ApplicationController
  
  def index
    @labels = current_user.labels.search_for(params[:q]).paginate(:page => params[:page])
    expires_in(5.minutes, :public => true)
  end
  
  def show
    @label = current_user.labels.find(params[:id])
    expires_in(5.minutes, :public => true)
  end
  
end
