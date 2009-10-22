class UploadsController < ApplicationController
  
  layout nil
  include UploadsHelper
  
  def show
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
    Track.import(
      :bucket => s3_upload_bucket || params[:bucket],
      :key => params[:key]
    )
    head :ok
  end
  
end
