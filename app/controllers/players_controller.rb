class PlayersController < ApplicationController
  
  before_filter :require_user_credentials
  
  def show
  end
  
  protected
  
    def require_user_credentials
      unless current_user.has_credentials?
        redirect_to credentials_account_path
      end
    end
  
end
