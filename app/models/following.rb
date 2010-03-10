class Following < ActiveRecord::Base
  belongs_to :user
  belongs_to :follower, :class_name => 'User'
  
  validates_presence_of :user_id
  validates_presence_of :follower_id
  validates_uniqueness_of :follower_id, :scope => [:user_id]
  
  def notify_user
    NotificationMailer.deliver_follow_notification(user, follower)
  end
  
  after_create :notify_user unless Rails.env.test?
  handle_asynchronously :notify_user
  
end
