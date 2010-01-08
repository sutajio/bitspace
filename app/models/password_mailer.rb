class PasswordMailer < ActionMailer::Base

  def reset_password_link(user)
    default_url_options[:host] = ENV['DOMAIN_NAME']
    from "Bitspace <noreply@#{ENV['DOMAIN_NAME']}>"
    recipients user.email
    subject "Reset your password"
    body :user => user
  end

end
