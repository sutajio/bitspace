class UsersController < ApplicationController
  before_filter :require_admin_user
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to artists_path
    else
      render :action => :new
    end
  end
end
