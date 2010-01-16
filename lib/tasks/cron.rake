task :cron => :environment do
  puts ">> Heartbeat at #{Time.now}"
  Rake::Task['cron:metadata'].invoke
end

namespace :cron do
  task :metadata => :environment do
    puts "-> Updating meta data."
    puts "Artists:"
    Artist.find_each do |artist|
      artist.update_meta_data_without_send_later
      print "."
      STDOUT.flush
    end
    puts
    puts "Labels:"
    Label.find_each do |label|
      label.update_meta_data_without_send_later
      print "."
      STDOUT.flush
    end
    puts
    puts "Releases:"
    Release.find_each do |release|
      release.update_meta_data_without_send_later
      print "."
      STDOUT.flush
    end
    puts
    puts "Tracks:"
    Track.find_each do |track|
      track.update_meta_data_without_send_later
      print "."
      STDOUT.flush
    end
    puts
    puts "-> Finished!"
  end
end