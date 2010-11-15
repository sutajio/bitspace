require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  
  test "invitation" do
    invitation = Invitation.create!(:email => 'test@example.com')
    assert InvitationMailer.create_invitation(invitation)
  end
  
end
