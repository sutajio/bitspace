task :cron => :environment do
  puts ">> Heartbeat at #{Time.now}"
  Rake::Task['cron:metadata'].invoke
end

namespace :cron do
  task :metadata => :environment do
    puts "-> Updating meta data."
    puts "Artists:"
    Artist.all(:limit => 10, :order => 'updated_at').each do |artist|
      artist.update_meta_data
      print "."
      STDOUT.flush
    end
    puts
    puts "Labels:"
    Label.all(:limit => 10, :order => 'updated_at').each do |label|
      label.update_meta_data
      print "."
      STDOUT.flush
    end
    puts
    puts "Releases:"
    Release.all(:limit => 10, :order => 'updated_at').each do |release|
      release.update_meta_data
      print "."
      STDOUT.flush
    end
    puts
    puts "Tracks:"
    Track.all(:limit => 10, :order => 'updated_at').each do |track|
      track.update_meta_data
      print "."
      STDOUT.flush
    end
    puts
    puts "-> Finished!"
  end
end