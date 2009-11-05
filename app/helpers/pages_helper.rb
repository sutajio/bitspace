module PagesHelper
  
  def bytes_per_album
    50.megabytes
  end
  
  def tracks_per_album
    10
  end
  
  def bytes_to_albums(bytes)
    if bytes
      number_with_delimiter(bytes / bytes_per_album)
    else
      'Unlimited'
    end
  end
  
  def bytes_to_tracks(bytes)
    if bytes
      number_with_delimiter((bytes / bytes_per_album) * tracks_per_album)
    else
      'Unlimited'
    end
  end
  
end
