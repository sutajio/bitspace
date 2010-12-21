require 'test_helper'

class DevicesControllerTest < ActionController::TestCase

  def setup
    @user = User.create!(:login => 'test', :email => 'test@example.com', :password => 'test', :password_confirmation => 'test')
  end

  test "filters invalid Base64" do
    post :create, :device => { :apns_token => 'abc def' }, :profile_id => @user.login
    assert_equal 'abc+def', assigns(:device).apns_token
  end

end
