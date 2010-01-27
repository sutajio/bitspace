class PasswordsController < ApplicationController
  
  skip_before_filter :require_user
  before_filter :find_user_using_perishable_token, :only => [:reset, :update]
  layout 'login'
  
  def forgot
  end
  
  def create
    @user = User.find_by_email(params[:email]) ||
            User.find_by_login(params[:email])
    raise ActiveRecord::RecordNotFound if @user.nil?
    @user.forgot_password
    flash[:notice] = 'Ok, we\'ve sent the instructions to your email. Go check it!'
    redirect_to forgot_password_path
  rescue ActiveRecord::RecordNotFound => e
    flash[:alert] = 'Oh, snap! We couldn\'t find you!'
    redirect_to forgot_password_path
  end
  
  def reset
  end
  
  def update
    @user.password = params[:password]
    @user.password_confirmation = params[:password]
    @user.save!
    redirect_to woohoo_password_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.full_messages.to_sentence
    redirect_to login_path
  end
  
  def woohoo
  end
  
  protected
  
    def find_user_using_perishable_token
      @user = User.find_using_perishable_token!(params[:token], 1.hour)
    rescue ActiveRecord::RecordNotFound => e
      flash[:alert] = 'Oh dear, that link seems to have expired.'
      redirect_to login_path
    end

end
