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
  
  include Facebooker::Rails::Controller
  
  before_filter :require_user
  before_filter :set_facebook_session
  
  rescue_from Facebooker::Session::SessionExpired do |exception|
    clear_facebook_session_information
    clear_fb_cookies!
    current_user_session.destroy if current_user_session
    redirect_to root_path
  end
  
  before_filter :require_chrome_frame_if_ie
  
  protected
    
    def current_layout
      if request.xhr?
        nil
      else
        current_user ? 'application' : 'site'
      end
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
        if request.xhr?
          render :text => "You must be logged in to access that page.", :status => :forbidden
        else
          redirect_to root_path
        end
        return false
      end
    end
    
    def require_no_user
      if current_user
        if request.xhr?
          render :text => "You must be logged out to access that page.", :status => :forbidden
        else
          redirect_to root_path
        end
        return false
      end
    end
    
    def require_admin_user
      unless current_user.is_admin?
        if request.xhr?
          render :text => "You must be admin access that page.", :status => :forbidden
        else
          redirect_to root_path
        end
        return false
      end
    end
    
    def require_connected_user
      if Rails.env.production?
        unless facebook_session
          if request.xhr?
            render :text => "You must connect to Facebook to access that page.", :status => :forbidden
          else
            redirect_to root_path
          end
        end
      end
    end
    
    def require_chrome_frame_if_ie
      if current_user
        if request.headers['User-Agent'].include?('MSIE')
          unless request.headers['User-Agent'].include?('chromeframe')
            redirect_to 'http://www.google.com/chromeframe'
          end
        end
      end
    end

end
