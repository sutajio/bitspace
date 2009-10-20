class Track < ActiveRecord::Base
  
  belongs_to :release
  belongs_to :artist
  
  validates_presence_of :release_id
  validates_presence_of :fingerprint
  validates_presence_of :title
  validates_presence_of :track_nr
  validates_presence_of :length
  validates_presence_of :size
  
  validates_uniqueness_of :mbid, :allow_nil => true
  validates_uniqueness_of :fingerprint
  validates_uniqueness_of :track_nr, :scope => [:release_id]
  
  default_scope :order => 'track_nr'
  
  class <<self
    def import(options)
      require 'tempfile'
      Tempfile.open('upload', File.join(Rails.root, 'tmp')) do |file|
        AWS::S3::Base.establish_connection!(
          :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'])
        
        AWS::S3::S3Object.stream(options[:key], options[:bucket]) do |chunk|
          file.write(chunk)
        end
        
        Mp3Info.open(file.path) do |mp3info|
          logger.info("Title: #{mp3info.tag.title}")
          logger.info("Artist: #{mp3info.tag.artist}")
          logger.info("Release: #{mp3info.tag.album}")
          logger.info("Year: #{mp3info.tag.year}")
          logger.info("Track No.: #{mp3info.tag.tracknum}")
          logger.info("Length: #{mp3info.length}")
          transaction do
            artist = Artist.find_or_create_by_name(mp3info.tag.artist)
            unless artist.valid?
              logger.debug(artist.errors.full_messages.to_sentence)
            end
            release = Release.find_or_create_by_title(
              :artist => artist,
              :title => mp3info.tag.album,
              :year => mp3info.tag.year)
            unless release.valid?
              logger.debug(release.errors.full_messages.to_sentence)
            end
            track = Track.find_or_create_by_title(
              :release => release,
              :fingerprint => generate_fingerprint(file),
              :title => mp3info.tag.title,
              :track_nr => mp3info.tag.tracknum,
              :length => mp3info.length,
              :size => file.size,
              :file => file)
            unless track.valid?
              logger.debug(track.errors.full_messages.to_sentence)
            end
          end
        end
        
        AWS::S3::S3Object.delete(options[:key], options[:bucket])
      end
    end
    
    handle_asynchronously :import
    
    def generate_fingerprint(file)
      Digest::SHA1.hexdigest(file.open.read)
    end
  end
  
  def url(use_cdn = true)
    if ENV['CDN_HOST'] && use_cdn
      "http://#{ENV['CDN_HOST']}/#{URI.escape(key)}"
    else
      "http://#{ENV['S3_BUCKET']}.#{AWS::S3::DEFAULT_HOST}/#{URI.escape(key)}"
    end
  end
  
  def torrent
    "#{url(false)}?torrent"
  end
  
  def key
    "tracks/#{fingerprint}.mp3"
  end
  
  attr_writer :file
  
  def upload_track
    if @file
      unless AWS::S3::S3Object.exists?(key, ENV['S3_BUCKET'])
        AWS::S3::S3Object.store(key, @file, ENV['S3_BUCKET'],
          :content_type => 'audio/mpeg',
          :access => :public_read)
        logger.info "Key: #{key}"
        return true
      end
    end
  end
  
  before_save :upload_track
  
end
