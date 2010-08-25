module PlaylistsHelper
  
  def first_handfull_of_releases_in_playlist(tracks)
    handfull_in_hard_numbers = (tracks.size/7.0).to_i
    releases = []
    tracks.each do |track|
      if releases.size < handfull_in_hard_numbers &&
         !releases.include?(track.release)
        releases << track.release
      end
    end
    releases
  end
  
end
