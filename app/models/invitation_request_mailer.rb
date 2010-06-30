class InvitationRequestMailer < ActionMailer::Base

  def notification(invitation_request)
    default_url_options[:host] = ENV['DOMAIN_NAME']
    from "Bitspace <noreply@#{ENV['DOMAIN_NAME']}>"
    recipients "beta@sutajio.se"
    subject "Invitation request from #{invitation_request.email}"
    body :invitation_request => invitation_request
  end

end
