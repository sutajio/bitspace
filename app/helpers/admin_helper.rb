module AdminHelper

  def job_status_as_dom_class(job)
    if job.locked_at.present?
      'locked'
    elsif job.failed_at.present?
      'failed'
    elsif job.run_at <= Time.now.utc
      'backlog'
    end
  end

end
