class SpacesController < ApplicationController
  
  def index
  end
  
  def show
    @space = Space.find(params[:id])
  end
  
end
