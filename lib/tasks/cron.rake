task :cron => :environment do
  puts ">> Heartbeat at #{Time.now}"
  #Rake::Task['destroy_orphans'].invoke
  Rake::Task['squish_names_and_titles'].invoke
  #Rake::Task['fix_featured_artists'].invoke
  #Rake::Task['fix_various_artists_releases'].invoke
  Rake::Task['cron:import_podcasts'].invoke
  Rake::Task['cron:metadata'].invoke
end

namespace :cron do
  task :metadata => :environment do
    puts "-> Updating meta data."
    puts "Artists:"
    Artist.without_archived.find_each do |artist|
      begin
        artist.archive! if artist.releases.without_archived.empty?
        artist.update_meta_data_without_send_later
        print "."
      rescue Object => e
        print "F"
      end
      STDOUT.flush
    end
    puts
    puts "Labels:"
    Label.without_archived.find_each do |label|
      begin
        label.archive! if label.releases.without_archived.empty?
        label.update_meta_data_without_send_later
        print "."
      rescue Object => e
        print "F"
      end
      STDOUT.flush
    end
    puts
    puts "Releases:"
    Release.without_archived.find_each do |release|
      begin
        release.update_meta_data_without_send_later
        print "."
      rescue Object => e
        print "F"
      end
      STDOUT.flush
    end
    puts
    puts "Tracks:"
    Track.find_each do |track|
      begin
        track.update_meta_data_without_send_later
        print "."
      rescue Object => e
        print "F"
      end
      STDOUT.flush
    end
    puts
    puts "-> Finished!"
  end
  
  task :import_podcasts => :environment do
    puts "-> Importing podcasts."
    Podcast.find_each do |podcast|
      podcast.import
      print "."
      STDOUT.flush
    end
    puts "-> Finished!"
  end
end