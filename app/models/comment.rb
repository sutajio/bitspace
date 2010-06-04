class Comment < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :commented, :polymorphic => true
  
  validates_presence_of :user_id
  validates_presence_of :commented_id, :commented_type
  validates_presence_of :body
  
  default_scope :order => 'created_at DESC'
  
  def send_comment_notification
    unless user == commented.user
      NotificationMailer.deliver_comment_notification(commented.user, self)
    end
    commented.comments.map(&:user).uniq.each do |user|
      unless user == self.user || user == commented.user
        NotificationMailer.deliver_comment_notification(user, self)
      end
    end
  end
  
  after_create :send_comment_notification unless Rails.env.test?
  handle_asynchronously :send_comment_notification
  
end
