module ReleasesHelper
  
  def release_title(release)
    if release.year.present?
      "#{h(release.artist.name)} &ndash; #{h(release.title)} (#{release.year})"
    else
      "#{h(release.artist.name)} &ndash; #{h(release.title)}"
    end
  end
  
  def artwork_release_path_with_session_information(release)
    session_key = ActionController::Base.session_options[:key]
    artwork_release_path(release, session_key => cookies[session_key], :request_forgery_protection_token => form_authenticity_token)
  end
  
  def release_to_hash(release, options = {})
    if options[:simple]
      {
        :id => release.id,
        :title => release.title,
        :url => release_url(release.id),
        :artist => release.artist.name,
        :artist_sort_name => release.artist.sort_name,
        :year => release.year,
        :release_date => release.release_date,
        :label => release.label,
        :small_artwork_url => release.artwork.file? ? release.artwork.url(:small, false) : nil,
        :medium_artwork_url => release.artwork.file? ? release.artwork.url(:medium, false) : nil,
        :large_artwork_url => release.artwork.file? ? release.artwork.url(:large, false) : nil,
        :created_at => release.created_at,
        :updated_at => release.updated_at,
        :archived => release.archived,
        :tracks => tracks_to_hash(release.tracks)
      }
    else
      {
        :id => release.id,
        :title => release.title,
        :url => release_url(release.id),
        :artist => {
          :id => release.artist.id,
          :name => release.artist.name,
          :sort_name => release.artist.sort_name,
          :artist_type => release.artist.artist_type,
          :begin_date => release.artist.begin_date,
          :end_date => release.artist.end_date,
          :website => release.artist.website,
          :small_artwork_url => release.artist.artwork.file? ? release.artist.artwork.url(:small, false) : nil,
          :large_artwork_url => release.artist.artwork.file? ? release.artist.artwork.url(:large, false) : nil,
          :biography_url => biography_artist_url(release.artist, :format => 'txt', :profile_id => @user.login),
          :releases_count => release.artist.releases_count,
          :created_at => release.artist.created_at,
          :updated_at => release.artist.updated_at,
          :archived => false #release.artist.archived
        },
        :year => release.year,
        :label => release.label ? { :name => release.label } : nil,
        :release_date => release.release_date,
        :small_artwork_url => release.artwork.file? ? release.artwork.url(:small, false) : nil,
        :medium_artwork_url => release.artwork.file? ? release.artwork.url(:medium, false) : nil,
        :large_artwork_url => release.artwork.file? ? release.artwork.url(:large, false) : nil,
        :created_at => release.created_at,
        :updated_at => release.updated_at,
        :archived => release.archived,
        :tracks => tracks_to_hash(release.tracks)
      }
    end
  end
  
  def release_to_json(release, options = {})
    release_to_hash(release, options).to_json
  end
  
end
