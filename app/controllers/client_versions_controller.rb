class ClientVersionsController < ApplicationController
  
  skip_before_filter :require_user
  before_filter :require_admin, :except => [:download]
  layout 'site'
  
  def new
    @client_version = ClientVersion.new
  end
  
  def create
    @client_version = ClientVersion.new(params[:client_version])
    @client_version.save!
    flash[:notice] = 'New version has been uploaded. Gokigen yō!'
    redirect_to new_client_version_path
  rescue ActiveRecord::RecordInvalid => e
    render :action => 'new'
  end
  
  def download
    @client_version = ClientVersion.find(params[:id])
    @client_version.increment!(:downloads)
    redirect_to @client_version.download.url(nil, false)
  end
  
end
