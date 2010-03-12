class ReleasesController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:update]
  
  def index
    @releases = current_user.releases.search_for(params[:q]).paginate(
        :page => params[:page],
        :per_page => 16,
        :include => [:artist],
        :order => 'created_at DESC',
        :conditions => { :archived => params[:q].present? ? [true,false] : false })
    if request.xhr? && @releases.empty?
      render :nothing => true
    end
  end
  
  def show
    @release = current_user.releases.find(params[:id])
  end
  
  def edit
    @release = current_user.releases.find(params[:id])
  end
  
  def update
    @release = current_user.releases.find(params[:id])
    if @release.update_attributes(params[:release])
      head :ok
    else
      render :text => @release.errors.full_messages.to_sentence
    end
  end
  
  def artwork
    @release = current_user.releases.find(params[:id])
    if request.put?
      @release.update_attributes!(:artwork => params[:release][:artwork])
      head :ok
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  end
  
  def archive
    @release = current_user.releases.find(params[:id])
    @release.toggle_archive!
    head :ok
  end
  
  def destroy
    @release = current_user.releases.find(params[:id])
    @release.destroy
    head :ok
  end
  
end
