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
  has_many :scrobbles
  has_many :invitations
  has_many :followings
  has_many :followers, :through => :followings, :order => 'followings.created_at DESC'
  has_many :subscriptions
  has_many :subscribers, :through => :subscriptions
  has_many :memberships, :foreign_key => 'subscriber_id', :class_name => 'Subscription'
  has_many :comments
  has_many :devices
  
  SUBSCRIPTION_PLANS = {
    :free => { :name => 'Bitspace Free', :storage => 500.megabytes, :price_in_euro => 0, :official => true },
    :beta => { :name => 'Bitspace Beta', :storage => 1.gigabyte, :price_in_euro => 0 },
    :basic => { :name => 'Bitspace Basic', :storage => 10.gigabyte, :price_in_euro => 3.99, :paypal_button_id => '9893430', :upgrade_button_id => '6A8KXB3ADVCQU', :official => true, :tagline => 'Great for small collections', :invitations => 20 },
    :standard => { :name => 'Bitspace Standard', :storage => 25.gigabyte, :price_in_euro => 7.99, :paypal_button_id => '9893454', :upgrade_button_id => 'F586DKKS47GCG', :official => true, :tagline => 'Great value for your money', :invitations => 40 },
    :premium => { :name => 'Bitspace Premium', :storage => 50.gigabytes, :price_in_euro => 14.99, :paypal_button_id => '9369035', :upgrade_button_id => 'KKB7JWVTNYF9S', :official => true, :tagline => 'Great for big collections', :invitations => 80 },
    :unlimited => { :name => 'Bitspace Unlimited', :storage => nil, :price_in_euro => 79.99, :paypal_button_id => '9369365', :upgrade_button_id => 'FG8GJHWEUB6V4' },
    :double_basic => { :name => 'Bitspace Double Basic', :storage => 20.gigabytes, :price_in_euro => 3.99, :paypal_button_id => 'BDXDFU269SKZC' },
    :double_standard => { :name => 'Bitspace Double Standard', :storage => 50.gigabytes, :price_in_euro => 7.99, :paypal_button_id => '932WV2DB6QV5S' },
    :double_premium => { :name => 'Bitspace Double Premium', :storage => 100.gigabytes, :price_in_euro => 14.99, :paypal_button_id => '5VL5583RRK4QJ' },
    :custom_200 => { :name => 'Bitspace Custom 200', :storage => 200.gigabytes, :price_in_euro => 29.99, :paypal_button_id => 'PVCKWTUL7XLVA' }
  }
  
  DISALLOWED_USERNAMES = 
    %w(player dashboard search uploads artists releases
       labels years tracks playlists lastfm signup users invitations
       invitation_requests user_sessions login logout signin signout password
       account price tour about download terms blog blog_posts admin clients
       client_versions developer)
  
  validates_uniqueness_of :facebook_uid, :allow_nil => true
  validates_uniqueness_of :email, :allow_nil => true
  validates_inclusion_of :subscription_plan,
    :in => SUBSCRIPTION_PLANS.values.map {|x| x[:name] }
  validates_exclusion_of :login, :in => DISALLOWED_USERNAMES
  
  validates_inclusion_of :subscription_price, :in => 1..99, :allow_nil => true
  validates_inclusion_of :subscription_currency, :in => %w(EUR USD SEK), :allow_nil => true  
  validates_inclusion_of :subscription_periodicity, :in => %w(weekly monthly yearly), :allow_nil => true
  
  attr_protected :max_storage
  
  def setup_subscription_plan_details
    plan = SUBSCRIPTION_PLANS.values.find {|x| x[:name] == subscription_plan }
    self.max_storage = plan ? plan[:storage] : SUBSCRIPTION_PLANS[:free][:storage]
    self.invitations_left = plan ? plan[:invitations] || 0 : 0
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
    tracks.originals.sum(:size)
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
    self.name = [options[:first_name], options[:last_name]].reject(&:blank?).join(' ')
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
    reset_perishable_token!
    PasswordMailer.deliver_reset_password_link(self)
  end
  
  handle_asynchronously :forgot_password
  
  def has_credentials?
    login.present? && crypted_password.present?
  end
  
  def notify_of_new_release(release)
    NotificationMailer.deliver_new_release(self, release)
  end
  
  handle_asynchronously :notify_of_new_release
  
  def follows?(user)
    user ? user.followers.include?(self) : false
  end
  
  def follow!(user)
    if user
      user.followings.create!(:follower => self)
    end
  end
  
  def unfollow!(user)
    if user
      user.followings.find_by_follower_id(self.id).try(:destroy)
    end
  end
  
  def subscribes_to?(user)
    return true if user == self
    return user ? user.subscribers.include?(self) : false
  end
  
  def subscription_price_with_currency
    case subscription_currency
    when 'EUR'
      "€#{subscription_price}"
    when 'USD'
      "$#{subscription_price}"
    when 'SEK'
      "#{subscription_price}kr"
    end
  end
  
  def subscription_periodicity_as_period
    case subscription_periodicity.to_sym
    when :monthly
      'month'
    when :weekly
      'week'
    when :yearly
      'year'
    end
  end
  
  def subscription_periodicity_as_letter_code
    case subscription_periodicity.to_sym
    when :monthly
      'M'
    when :weekly
      'W'
    when :yearly
      'Y'
    end
  end
  
  def handle_prepaid_label_subscriptions
    prepaid_db = YAML.load(
      File.open(File.join(Rails.root, 'db/prepaid.yml')).read)
    prepaid_db.keys.each do |key|
      if prepaid_db[key].include?(self.email)
        label = User.find_by_login(key)
        Subscription.create!(
          :user => label,
          :subscriber => self)
      end
    end
  end
  
  after_create :handle_prepaid_label_subscriptions
  
end