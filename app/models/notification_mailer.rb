class NotificationMailer < ActionMailer::Base

  def new_release(user, release)
    default_url_options[:host] = ENV['DOMAIN_NAME']
    from "Bitspace <noreply@#{ENV['DOMAIN_NAME']}>"
    recipients user.email
    subject "#{release.user.login} has uploaded a new release by #{release.artist.name}"
    body :user => user, :release => release
  end
  
  def follow_notification(user, follower)
    default_url_options[:host] = ENV['DOMAIN_NAME']
    from "Bitspace <noreply@#{ENV['DOMAIN_NAME']}>"
    recipients user.email
    subject "#{follower.login} is now following you on Bitspace!"
    body :user => user, :follower => follower
  end
  
  def comment_notification(user, comment)
    default_url_options[:host] = ENV['DOMAIN_NAME']
    from "Bitspace <noreply@#{ENV['DOMAIN_NAME']}>"
    recipients user.email
    if user == comment.commented.user
      subject "#{comment.user.login} has commented on one of your releases..."
    elsif comment.user == comment.commented.user
      subject "#{comment.user.login} also commented on his release..."
    else
      subject "#{comment.user.login} also commented on #{comment.commented.user.login}'s release..."
    end
    body :user => user, :comment => comment
  end

end
