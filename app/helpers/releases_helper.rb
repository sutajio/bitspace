module ReleasesHelper
  
  def release_title(release)
    if release.year.present?
      "#{h(release.artist.name)} &ndash; #{h(release.title)} (#{release.year})"
    else
      "#{h(release.artist.name)} &ndash; #{h(release.title)}"
    end
  end
  
end
