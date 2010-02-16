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
  
  def approximate_revenue_in_sek
    euro_sek_rate = 9.8
    User::SUBSCRIPTION_PLANS.values.map do |plan|
      User.count(:conditions => { :subscription_plan => plan[:name] }) * plan[:price_in_euro]
    end.inject(0.0) {|sum,x| sum += x } * euro_sek_rate
  end
  
  def approximate_cost_in_sek
    storage_cost_per_gb_in_sek = 1.0
    (approximate_storage_usage_in_gb * storage_cost_per_gb_in_sek) +
    approximate_bandwidth_cost_in_sek
  end
  
  def approximate_storage_usage_in_gb
    Track.sum(:size, :group => 'fingerprint').values.sum / 1.gigabyte
  end
  
  def approximate_bandwidth_cost_in_sek
    User.count * 7.2
  end

end
