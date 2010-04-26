# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  
  layout :current_layout
  
  before_filter :require_user
  helper_method :current_user_session, :current_user
  
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
          respond_to do |format|
            format.html { session[:return_to] = params[:return_to]; redirect_to login_path }
            format.json { render :text => 'Invalid username or password.', :status => :unauthorized }
          end
        end
        return false
      end
    end
    
    def require_no_user
      if current_user
        if request.xhr?
          render :text => "You must be logged out to access that page.", :status => :forbidden
        else
          respond_to do |format|
            format.html { redirect_to player_path(:trailing_slash => true) }
            format.json { head :forbidden }
          end
        end
        return false
      end
    end
    
    def require_admin_user
      unless current_user.is_admin?
        if request.xhr?
          render :text => "You must be admin to access that page.", :status => :forbidden
        else
          respond_to do |format|
            format.html { redirect_to login_path }
            format.json { head :forbidden }
          end
        end
        return false
      end
    end
    
    def require_chrome_frame_if_ie
      if current_user
        if (request.headers['User-Agent'] || []).include?('MSIE')
          unless request.headers['User-Agent'].include?('chromeframe')
            render :template => 'errors/msie', :status => :bad_request, :layout => 'site'
          end
        end
      end
    end
    
    def require_admin
      authenticate_or_request_with_http_basic do |username, password|
        username == 'admin' && password == ENV['ADMIN_PASSWORD']
      end
    end
    
    def single_access_allowed?
      true
    end

end
