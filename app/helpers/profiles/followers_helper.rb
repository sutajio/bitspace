module Profiles::FollowersHelper
  
  def gravatar_url(user)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}.jpg?s=40&d=#{CGI.escape(root_url+'images/user.png')}"
  end
  
end
