class LabelsController < ApplicationController
  
  def index
    @labels = Label.search_for(params[:q]).paginate(:page => params[:page])
    expires_in(5.minutes, :public => true)
  end
  
  def show
    @label = Label.find(params[:id])
    expires_in(5.minutes, :public => true)
  end
  
end
