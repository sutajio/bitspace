class UploadsController < ApplicationController
  
  layout nil
  include UploadsHelper
  
  def new
    respond_to do |with|
      with.html
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
    @upload = Upload.new(params[:upload].reverse_merge(:bucket => s3_upload_bucket))
    @upload.save!
    Delayed::Job.enqueue(@upload, 1)
    head :ok
  end
  
end
