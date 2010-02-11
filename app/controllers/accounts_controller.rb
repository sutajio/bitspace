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
  
  def profile
    if request.put?
      if current_user.valid_password?(params[:password])
        current_user.email = params[:user][:email] if params[:user][:email].present?
        current_user.login = params[:user][:login] if params[:user][:login].present?
        current_user.password = params[:user][:password] if params[:user][:password].present?
        current_user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation].present?
        if current_user.save
          head :ok
        else
          render :text => current_user.errors.full_messages.to_sentence, :status => :bad_request
        end
      else
        render :text => 'Invalid password', :status => :forbidden
      end
    end
  end
  
  def valid_password
    if current_user.valid_password?(params[:password])
      render :json => true
    else
      render :json => false
    end
  end
  
end
