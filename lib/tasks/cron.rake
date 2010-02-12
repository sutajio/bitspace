task :cron => :environment do
  puts ">> Heartbeat at #{Time.now}"
  Rake::Task['cron:metadata'].invoke
end

namespace :cron do
  task :metadata => :environment do
    puts "-> Updating meta data."
    puts "Artists:"
    Artist.find_each do |artist|
      begin
        artist.update_meta_data_without_send_later
        print "."
      rescue Object => e
        print "F"
      end
      STDOUT.flush
    end
    puts
    puts "Labels:"
    Label.find_each do |label|
      begin
        label.update_meta_data_without_send_later
        print "."
      rescue Object => e
        print "F"
      end
      STDOUT.flush
    end
    puts
    puts "Releases:"
    Release.find_each do |release|
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
end