module PagesHelper
  
  def bytes_per_album
    50.megabytes
  end
  
  def tracks_per_album
    10
  end
  
  def bytes_to_albums(bytes)
    if bytes
      number_with_delimiter(number_without_precision(bytes / bytes_per_album))
    else
      'Unlimited'
    end
  end
  
  def bytes_to_tracks(bytes)
    if bytes
      number_with_delimiter(number_without_precision((bytes / bytes_per_album) * tracks_per_album))
    else
      'Unlimited'
    end
  end
  
  def number_without_precision(number)
    cardinality = ((Math.log(number) / Math.log(10)).to_i)
    cardinality = 10 ** cardinality
    number / cardinality * cardinality
  end
  
end
