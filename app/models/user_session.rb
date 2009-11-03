class UserSession < Authlogic::Session::Base
  include AuthlogicFacebookConnect::Session
  facebook_valid_user false
end