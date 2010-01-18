class LastfmController < ApplicationController

  def authorize
    redirect_to Lastfm.auth_url
  end

  def callback
    result = Lastfm.ws_call('auth.getSession', :token => params[:token])
    current_user.update_attributes(
      :lastfm_session_key => result['session']['key'],
      :lastfm_username => result['session']['name'],
      :lastfm_subscriber => result['session']['subscriber'].to_i)
    current_user.save
    redirect_to player_path(:trailing_slash => true)
  end

end
