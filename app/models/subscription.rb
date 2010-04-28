class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :subscriber, :class_name => 'User'
  
  validates_presence_of :user_id
  validates_presence_of :subscriber_id
  validates_uniqueness_of :subscriber_id, :scope => [:user_id]
  
  def give_all_releases_to_subscriber
    user.releases.all(:order => 'created_at').each do |release|
      release.copy(subscriber)
    end
  end
  
  after_create :give_all_releases_to_subscriber unless Rails.env.test?
  handle_asynchronously :give_all_releases_to_subscriber
  
end
