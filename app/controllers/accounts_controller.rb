class AccountsController < ApplicationController
  
  layout 'login', :only => [:credentials]
  
  def show
  end
  
  def credentials
    if request.put?
      current_user.login = params[:user][:login]
      current_user.password = params[:user][:password]
      current_user.password_confirmation = params[:user][:password]
      if current_user.save
        redirect_to player_path(:trailing_slash => true)
      end
    end
  end
  
end
