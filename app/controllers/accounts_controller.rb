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
        current_user.website = params[:user][:website] if params[:user][:website].present?
        current_user.biography = params[:user][:biography] if params[:user][:biography].present?
        current_user.public_profile = params[:user][:public_profile] if params[:user][:public_profile].present?
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
  
  def lastfm_scrobbling
    current_user.toggle!(:scrobble_to_lastfm)
    head :ok
  end
  
  def reset_api_token
    current_user.reset_single_access_token!
    render :text => current_user.single_access_token
  end
  
  def invitations
    @invitation = Invitation.new(params[:invitation])
    if request.post?
      @invitation.user = current_user
      @invitation.save!
      head :ok
    end
  end
  
  def status
    @since = Time.parse(params[:since])
    @nr_new_tracks = current_user.tracks.count(:conditions => ['created_at > ?', @since.utc])
    if @nr_new_tracks > 0
      render :text => "#{self.class.helpers.pluralize(@nr_new_tracks, 'new track')} added to your library."
    else
      head :ok
    end
  end
  
end
