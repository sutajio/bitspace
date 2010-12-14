class ReleaseObserver < ActiveRecord::Observer
  
  def after_create(release)
    notify_devices(release)
    notify_followers(release)
    give_to_subscribers(release)
  end
  
  def notify_devices(release)
    unless release.archived?
      if release.user.public_profile?
        release.user.notify_devices do
          { :alert => "A new release is available. Go check it out!",
            :badge => 1,
            :sound => 'default' }
        end
      end
    end
  end
  
  def notify_followers(release)
    unless release.archived?
      if release.user.public_profile?
        release.user.followers.each do |follower|
          follower.notify_of_new_release(release)
        end
      end
    end
  end
  
  def give_to_subscribers(release)
    unless release.archived?
      release.user.subscribers.each do |subscriber|
        release.sideload(subscriber)
        subscriber.notify_of_new_release(release)
      end
    end
  end
  
  handle_asynchronously :notify_devices, :run_at => lambda { 1.hour.from_now }
  handle_asynchronously :notify_followers, :run_at => lambda { 1.hour.from_now }
  handle_asynchronously :give_to_subscribers, :run_at => lambda { 1.hour.from_now }
  
end