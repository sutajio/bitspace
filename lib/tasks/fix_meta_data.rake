task :destroy_orphans => :environment do
  puts "-> Destroying orphans"
  Artist.find_each do |artist|
    if artist.releases.count == 0
      puts artist.name
      artist.destroy
    end
  end
  puts "-> Finished!"
end

task :merge_duplicates => :environment do
  puts "-> Merging duplicates"
  Artist.find_each do |artist|
    other_artists = artist.user.artists.find(:all, :conditions => ['name = ? AND user_id = ? AND id != ?', artist.name, artist.user_id, artist.id])
    if other_artists.size > 0
      puts "#{artist.name} (#{other_artists.size})"
      other_artists.each do |other_artist|
        other_artist.merge!(artist)
      end
    end
  end
  puts "-> Finished!"
end

task :squish_names_and_titles => :environment do
  puts "-> Squishing names and titles"
  Artist.find_each do |artist|
    artist.name = artist.name.squish
    puts artist.name if artist.changed?
    artist.save
  end
  Release.find_each do |release|
    release.title = release.title.squish
    puts release.title if release.changed?
    release.save
  end
  Label.find_each do |label|
    label.name = label.name.squish
    puts label.name if label.changed?
    label.save
  end
  Track.find_each do |track|
    track.title = track.title.squish
    puts track.title if track.changed?
    track.save
  end
  puts "-> Finished!"
end

task :fix_featured_artists => :environment do
  puts "-> Fixing featured artists"
  User.find_each do |user|
    puts "#{user.login}"+("-"*(80-user.login.try(:length).to_i))
    user.artists.all.each do |artist|
      [' feat. ', ' feat ', ' featuring ', ' ft. ', ' ft ',
       ' Feat. ', ' Feat ', ' Featuring ', ' Ft. ', ' Ft '].each do |feat|
        name_parts = artist.name.split(feat)
        album_artist_name = name_parts.first
        track_artist_name = name_parts.last
        if album_artist_name != track_artist_name
          if artist.releases.size > 0
            puts "#{album_artist_name} feat. #{track_artist_name} (#{artist.releases.size}, #{artist.releases.inject(0){|sum,x| sum += x.tracks.count }})"
            artist.releases.each do |release|
              release.rename_artist(album_artist_name)
              release.tracks.each do |track|
                puts "  > #{release.title} - #{track.title}"
                release.rename_tracks(track.id => { :title => track_artist_name })
              end
            end
          end
        end
      end
    end
  end
  puts "-> Finished!"
end

task :fix_various_artists_releases => :environment do
  puts "-> Fixing various artists releases"
  User.find_each do |user|
    puts "#{user.login}"+("-"*(80-user.login.try(:length).to_i))
    user.releases.all.each do |release|
      if release.could_be_various_artists?
        other_releases = user.releases.find(:all, :conditions => { :title => release.title })
        if other_releases.size > 1
          puts "#{release.artist.name} - #{release.title} (#{other_releases.size})"
          other_releases.each do |other_release|
            if other_release.artist.name != Upload.various_artists && release.could_be_various_artists?
              puts "  - #{other_release.artist.name} - #{other_release.title}"
              artist_name = other_release.artist.name
              other_release.tracks.each do |track|
                other_release.rename_tracks(track.id => { :artist => artist_name })
              end
              other_release.rename_artist(Upload.various_artists)
            end
          end
        end
      end
    end
  end
  puts "-> Finished!"
end