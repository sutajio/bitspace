class ClientsController < ApplicationController

  skip_before_filter :require_user
  before_filter :find_client
  layout nil

  def changelog
  end

  def release_notes
  end

  def download
    @client_version = @client.client_versions.first
    @client_version.increment!(:downloads)
    redirect_to @client_version.download.url(nil, false)
  end

  protected

    def find_client
      @client = Client.find_by_slug(params[:id])
      raise ActiveRecord::RecordNotFound if @client.nil?
    end

end
