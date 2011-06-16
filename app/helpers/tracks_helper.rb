module TracksHelper
  
  def seconds_to_time(seconds)
    if seconds < 10.seconds
      "0:0#{seconds.to_i}"
    elsif seconds < 1.minute
      "0:#{seconds.to_i}"
    elsif seconds < 1.hour
      Time.at(seconds.to_i).gmtime.strftime('%M:%S').gsub(/^0([1-9]+)/,'\1')
    elsif seconds < 24.hours
      Time.at(seconds.to_i).gmtime.strftime('%R:%S').gsub(/^0([1-9]+)/,'\1')
    else
      pluralize(seconds / 60 / 60 / 24, 'day')
    end
  end
  
  def tracks_to_hash(tracks, options = {})
    tracks.map {|track|
      {
        :id => track.id.to_s,
        :title => track.title,
        :url => track.url,
        :artist => track.artist.try(:name),
        :track_nr => track.track_nr,
        :set_nr => track.set_nr,
        :length => track.length,
        :now_playing_url => "http://api.bitspaceapp.com/now_playing?id=#{track.id}",
        :scrobble_url => "http://api.bitspaceapp.com/scrobble?id=#{track.id}",
        :love_url => "http://api.bitspaceapp.com/love?id=#{track.id}",
        :loved_at => track.loved_at
      }
    }
  end
  
  def tracks_to_json(tracks, options = {})
    tracks_to_hash(tracks, options).to_json
  end
  
end
