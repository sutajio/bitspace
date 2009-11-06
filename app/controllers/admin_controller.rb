class AdminController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  before_filter :authenticate

  def status
  end

  def jobs
    @jobs = Delayed::Job.paginate(:page => params[:page], :conditions => ['last_error IS NOT NULL'], :order => 'run_at')
  end

  def run_job
    @job = Delayed::Job.find(params[:id])
    @job.run_at = Time.now
    @job.save
    redirect_to :back
  end
  
  def delete_job
    @job = Delayed::Job.find(params[:id])
    @job.destroy
    redirect_to :back
  end

  protected

    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == 'admin' && password == ENV['ADMIN_PASSWORD']
      end
    end

end
