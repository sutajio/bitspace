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
      if options[:simple]
        {
          :title => track.title,
          :url => track.url,
          :artist => track.artist.try(:name),
          :track_nr => track.track_nr,
          :set_nr => track.set_nr,
          :length => track.length,
          :now_playing_url => now_playing_track_url(track),
          :scrobble_url => scrobble_track_url(track),
          :love_url => love_track_url(track),
          :loved_at => track.loved_at
        }
      else
        {
          :title => track.title,
          :url => track.url,
          :release => track.release.title,
          :artist => track.artist.try(:name),
          :album_artist => track.release.artist.name,
          :track_nr => track.track_nr,
          :set_nr => track.set_nr,
          :length => track.length,
          :track_url => release_url(track.release.id, :anchor => dom_id(track)),
          :release_url => release_url(track.release.id),
          :artist_url => artist_url(track.release.artist.id),
          :now_playing_url => now_playing_track_url(track),
          :scrobble_url => scrobble_track_url(track),
          :love_url => love_track_url(track),
          :loved_at => track.loved_at
        }
      end
    }
  end
  
  def tracks_to_json(tracks, options = {})
    tracks_to_hash(tracks, options).to_json
  end
  
end
