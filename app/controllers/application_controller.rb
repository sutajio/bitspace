# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
  layout :current_layout
  
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user
  
  before_filter :require_user
  
  protected
    
    def current_layout
      request.xhr? ? nil : 'application'
    end
    
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def require_user
      unless current_user
        render :text => "You must be logged in to access that page.", :status => :forbidden
        return false
      end
    end
    
    def require_no_user
      if current_user
        render :text => "You must be logged out to access that page.", :status => :forbidden
        return false
      end
    end
    
    def require_admin_user
      unless current_user.is_admin?
        render :text => "You must be admin to access that page.", :status => :forbidden
        return false
      end
    end

end
