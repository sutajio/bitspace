class UploadsController < ApplicationController
  
  layout nil
  include UploadsHelper
  
  before_filter :enforce_storage_constraints
  skip_before_filter :verify_authenticity_token, :only => [:create, :import]
  
  def new
    respond_to do |with|
      with.json do
        render :json => {
          :url => s3_upload_url,
          :params => s3_upload_params(
            :AWSAccessKeyId => ENV['AMAZON_ACCESS_KEY_ID'],
            :AWSSecretAccessKey => ENV['AMAZON_SECRET_ACCESS_KEY']),
          :file_param => s3_upload_file_param
        }
      end
    end
  end
  
  def create
    @upload = Upload.new(
      params[:upload].reverse_merge(
        :bucket => s3_upload_bucket).merge(
        :user_id => current_user.id))
    @upload.save!
    Delayed::Job.enqueue(@upload, 1)
    render :json => @upload
  end
  
  def import
    @upload = Upload.new(:user_id => current_user.id, :key => params[:url])
    @upload.save!
    Delayed::Job.enqueue(@upload, 1)
    render :json => @upload
  end
  
  protected
  
    def enforce_storage_constraints
      if current_user.storage_left <= 0
        render :text => "You don't have any space left. Sorry!", :status => :payment_required
      end
    end
  
end
