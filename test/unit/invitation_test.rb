require 'test_helper'

class InvitationTest < ActiveSupport::TestCase

  test "create invitation" do
    invitation = Invitation.create!(:email => 'test@example.com')
    assert invitation.token
  end
  
  test "send invitation" do
    invitation = Invitation.create!(:email => 'test@example.com')
    invitation.send_invitation_without_send_later
  end
  
  test "send invitation to friend" do
    user = User.create!(:login => 'test', :email => 'test@example.com', :password => '123456', :password_confirmation => '123456')
    user.invitations_left = 1
    Invitation.create!(:user => user, :email => 'test@example.com')
    assert_equal 0, user.invitations_left
  end
  
  test "no invitations left" do
    user = User.create!(:login => 'test', :email => 'test@example.com', :password => '123456', :password_confirmation => '123456', :invitations_left => 0)
    assert_raises ActiveRecord::RecordInvalid do
      Invitation.create!(:user => user, :email => 'test@example.com')
    end
  end

end
