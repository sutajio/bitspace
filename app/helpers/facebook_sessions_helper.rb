module FacebookSessionsHelper
  
  def facebook_login_button(button_text = 'Sign in with Facebook')
    "<fb:login-button v=\"2\" size=\"medium\" onlogin=\"connect_to_facebook()\">#{button_text}</fb:login-button>" +
    form_tag(facebook_sessions_path, :method => :post, :id => 'connect-to-facebook-form') + '</form>' +
    "<script type=\"text/javascript\" charset=\"utf-8\">
      function connect_to_facebook() {
        $('#connect-to-facebook-form').submit();
      }
    </script>"
  end
  
end
