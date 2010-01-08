class InvitationMailer < ActionMailer::Base

  def invitation(invitation)
    default_url_options[:host] = ENV['DOMAIN_NAME']
    from "Bitspace <noreply@#{ENV['DOMAIN_NAME']}>"
    recipients invitation.email
    subject "Welcome to Bitspace"
    body :invitation => invitation
  end

end
