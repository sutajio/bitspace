module ProfilesHelper
  
  def url_without_protocol(url)
    return unless url
    match = url.match(/^.+:\/\/(.+)\/?$/)
    nice_url = match ? match[1] : url
    nice_url[-1..-1] == '/' ? nice_url[0..-2] : nice_url
  end
  
  def release_date(release)
    release.release_date ? release.release_date.to_formatted_s(:long_ordinal) : release.year
  end
  
end
