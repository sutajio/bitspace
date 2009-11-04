class InvitationMailer < ActionMailer::Base

  def invitation(invitation)
    default_url_options[:host] = 'bitspace.at'
    from "Bitspace.at <noreply@bitspace.at>"
    recipients invitation.email
    subject "Welcome to Bitspace"
    body :invitation => invitation
  end

end
