module ArtistsHelper
  
  def artwork_artist_path_with_session_information(artist)
    session_key = ActionController::Base.session_options[:key]
    artwork_artist_path(artist, session_key => cookies[session_key], :request_forgery_protection_token => form_authenticity_token)
  end
  
end
