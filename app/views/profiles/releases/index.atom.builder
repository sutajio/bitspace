atom_feed(:root_url => releases_profile_url(@user.login)) do |feed|
  feed.title "Bitspace @ #{@user.login}"
  feed.updated @releases.first.created_at
  @releases.each do |release|
    feed.entry(release, :url => formatted_release_profile_url(@user.login, release)) do |entry|
      entry.title "#{release.artist.name} – #{release.title}" + (release.year? ? " (#{release.year})" : '')
    end
  end
end