class AdminController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  before_filter :authenticate

  def status
  end

  protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == 'admin' && password == ENV['ADMIN_PASSWORD']
      end
    end

end
