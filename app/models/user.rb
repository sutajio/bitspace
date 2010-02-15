class User < ActiveRecord::Base
  acts_as_authentic do
    merge_validates_uniqueness_of_login_field_options :case_sensitive => true
    merge_validates_format_of_login_field_options :with => /^[a-z][a-z0-9_]+$/,
      :message => 'Should use only lowercase letters, numbers, and underscore please.'
  end
  
  has_many :artists
  has_many :releases
  has_many :tracks
  has_many :labels
  
  SUBSCRIPTION_PLANS = {
    :free => { :name => 'Bitspace Free', :storage => 500.megabytes, :price_in_euro => 0, :official => true },
    :beta => { :name => 'Bitspace Beta', :storage => 1.gigabyte, :price_in_euro => 0 },
    :basic => { :name => 'Bitspace Basic', :storage => 10.gigabyte, :price_in_euro => 3.99, :paypal_button_id => '9893430', :official => true, :tagline => 'Great way to start out' },
    :standard => { :name => 'Bitspace Standard', :storage => 25.gigabyte, :price_in_euro => 7.99, :paypal_button_id => '9893454', :official => true, :tagline => 'Great value for your money' },
    :premium => { :name => 'Bitspace Premium', :storage => 50.gigabytes, :price_in_euro => 14.99, :paypal_button_id => '9369035', :official => true, :tagline => 'Great for big collections' },
    :unlimited => { :name => 'Bitspace Unlimited', :storage => nil, :price_in_euro => 79.99, :paypal_button_id => '9369365' },
    :double_basic => { :name => 'Bitspace Double Basic', :storage => 20.gigabytes, :price_in_euro => 3.99, :paypal_button_id => 'BDXDFU269SKZC' },
    :double_standard => { :name => 'Bitspace Double Standard', :storage => 50.gigabytes, :price_in_euro => 7.99, :paypal_button_id => '932WV2DB6QV5S' },
    :double_premium => { :name => 'Bitspace Double Premium', :storage => 100.gigabytes, :price_in_euro => 14.99, :paypal_button_id => '5VL5583RRK4QJ' }
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
      1.0/0 # Infinity
    end
  end
  
  def storage_used
    tracks.sum(:size)
  end
  
  def storage_used_in_percent
    if self.max_storage && self.max_storage != 0
      (self.storage_used.to_f / self.max_storage.to_f) * 100.0
    else
      0.0
    end
  end
  
  def paying_customer?
    subscription_plan == SUBSCRIPTION_PLANS[:beta][:name] ||
    subscription_plan != SUBSCRIPTION_PLANS[:free][:name]
  end
  
  def upgrade_subscription_plan!(options = {})
    self.first_name = options[:first_name]
    self.last_name = options[:last_name]
    self.subscription_id = options[:subscription_id]
    self.subscription_plan = options[:subscription_plan]
    self.setup_subscription_plan_details
    self.save!
  end
  
  def handle_failed_payment!
    
  end
  
  def cancel_subscription!
    self.subscription_plan = SUBSCRIPTION_PLANS[:free][:name]
    self.setup_subscription_plan_details
    self.save!
  end
  
  def connected_to_lastfm?
    self.lastfm_session_key.present? &&
    self.lastfm_username.present?
  end
  
  def forgot_password
    PasswordMailer.deliver_reset_password_link(self)
  end
  
  handle_asynchronously :forgot_password
  
  def has_credentials?
    login.present? && crypted_password.present?
  end
  
end