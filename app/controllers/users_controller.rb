class UsersController < ApplicationController
  skip_before_filter :require_user
  before_filter :require_connected_user
  #before_filter :require_invited_user, :only => [:create]
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_path
    else
      render :action => :new
    end
  end
end
