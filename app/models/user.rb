class User < ActiveRecord::Base
  acts_as_authentic do
    validate_login_field false
    validate_password_field false
    validate_email_field false
  end
  
  SUBSCRIPTION_PLANS = {
    :free => { :name => 'Bitspace Free', :storage => 500.megabytes, :price_in_euro => 0 },
    :beta => { :name => 'Bitspace Beta', :storage => 1.gigabyte, :price_in_euro => 0 },
    :premium => { :name => 'Bitspace Premium', :storage => 25.gigabytes, :price_in_euro => 7.99 },
    :unlimited => { :name => 'Bitspace Unlimited', :storage => nil, :price_in_euro => 79.99 }
  }
  
  validates_uniqueness_of :facebook_uid, :allow_nil => true
  validates_uniqueness_of :email, :allow_nil => true
  validates_inclusion_of :subscription_plan,
    :in => SUBSCRIPTION_PLANS.values.map {|x| x[:name] }
  
  attr_protected :max_storage
  
  def setup_subscription_plan_details
    plan = SUBSCRIPTION_PLANS.values.find {|x| x[:name] == subscription_plan }
    self.max_storage = plan ? plan[:storage] : SUBSCRIPTION_PLANS[:free][:storage]
  end
  
  before_validation_on_create :setup_subscription_plan_details
  
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
  
  def paying_customer?
    subscription_plan != SUBSCRIPTION_PLANS[:free][:name]
  end
  
  def handle_failed_payment
    
  end
  
  def cancel_subscription
    self.subscription_plan = SUBSCRIPTION_PLANS[:free][:name]
    self.setup_subscription_plan_details
    self.save!
  end
  
end