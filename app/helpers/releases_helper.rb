module ReleasesHelper
  
  def release_title(release)
    if release.year.present?
      "#{h(release.artist.name)} &ndash; #{h(release.title)} (#{release.year})"
    else
      "#{h(release.artist.name)} &ndash; #{h(release.title)}"
    end
  end
  
  def release_path_with_session_information(release)
    session_key = ActionController::Base.session_options[:key]
    release_path(release, session_key => cookies[session_key], :request_forgery_protection_token => form_authenticity_token)
  end
  
end
