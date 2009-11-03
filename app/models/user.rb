class User < ActiveRecord::Base
  acts_as_authentic do
    validate_login_field false
    validate_password_field false
  end
  
  def before_connect(facebook_session)
    self.name = facebook_session.user.name
  end
  
  SUBSCRIPTION_PLANS = 
    { :free => 'Bitspace Free',
      :premium => 'Bitspace Premium',
      :unlimited => 'Bitspace Unlimited' }
  
  validates_inclusion_of :subscription_plan, :in => SUBSCRIPTION_PLANS.values
  attr_protected :max_storage, :subscription_plan
  
  def setup_subscription_plan_details
    case subscription_plan
    when SUBSCRIPTION_PLANS[:free]:
      self.max_storage = 1.gigabyte
    when SUBSCRIPTION_PLANS[:premium]:
      self.max_storage = 50.gigabytes
    when SUBSCRIPTION_PLANS[:unlimited]:
      self.max_storage = nil
    end
  end
  
  before_create :setup_subscription_plan_details
  
  def storage_left
    if self.max_storage
      self.max_storage - self.storage_used
    else
      Infinity
    end
  end
  
  def storage_used
    Track.sum(:size)
  end
  
end