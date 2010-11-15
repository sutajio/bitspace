require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase
  
  test "new release" do
    user = User.create!(:login => 'test', :email => 'test@example.com', :password => '123456', :password_confirmation => '123456')
    artist = user.artists.create!(:name => 'Test')
    release = artist.releases.create!(:title => 'Test', :user => user)
    assert NotificationMailer.create_new_release(user, release)
  end
  
  test "follow notification" do
    user = User.create!(:login => 'test', :email => 'test@example.com', :password => '123456', :password_confirmation => '123456')
    follower = User.create!(:login => 'follower', :email => 'follower@example.com', :password => '123456', :password_confirmation => '123456')
    assert NotificationMailer.create_follow_notification(user, follower)
  end
  
  test "comment notification" do
    user = User.create!(:login => 'test', :email => 'test@example.com', :password => '123456', :password_confirmation => '123456')
    artist = user.artists.create!(:name => 'Test')
    release = artist.releases.create!(:title => 'Test', :user => user)
    comment = Comment.create!(:user => user, :commented => release, :body => '...')
    assert NotificationMailer.create_comment_notification(user, comment)
  end
  
end
