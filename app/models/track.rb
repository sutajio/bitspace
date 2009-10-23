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
  
  cattr_accessor :unknown_artist
  self.unknown_artist = '[Unknown Artist]'
  
  cattr_accessor :unknown_release
  self.unknown_release = '[Unknown Release]'
  
  cattr_accessor :unknown_title
  self.unknown_title = '[Unknown Title]'
  
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
        
        logger.info("Importing #{options[:key]}")
        
        Mp3Info.open(file.path) do |mp3info|
          
          artist_name = 
            mp3info.tag.artist.blank? ? 
              parse_filename(options[:key])[:artist] : mp3info.tag.artist
          release_title = 
            mp3info.tag.album.blank? ? 
              parse_filename(options[:key])[:release] : mp3info.tag.album
          release_year = 
            mp3info.tag.year.blank? ? 
              parse_filename(options[:key])[:year] : mp3info.tag.year
          track_title = 
            mp3info.tag.title.blank? ? 
              parse_filename(options[:key])[:title] : mp3info.tag.title
          track_nr =
            mp3info.tag.tracknum.blank? ?
              parse_filename(options[:key])[:track_nr] : mp3info.tag.tracknum
          
          logger.info("Title: #{track_title}")
          logger.info("Artist: #{artist_name}")
          logger.info("Release: #{release_title}")
          logger.info("Year: #{release_year}")
          logger.info("Track No.: #{track_nr}")
          logger.info("Length: #{mp3info.length}")
          logger.info("Bitrate: #{mp3info.bitrate}")
          logger.info("Sample rate: #{mp3info.samplerate}")
          logger.info("VBR: #{mp3info.vbr}")
          
          transaction do
            artist = Artist.find_or_create_by_name(artist_name)
            unless artist.valid?
              logger.error(artist.errors.full_messages.to_sentence)
            end
            release = Release.find_or_create_by_title(
              :artist => artist,
              :title => release_title,
              :year => release_year)
            unless release.valid?
              logger.error(release.errors.full_messages.to_sentence)
            end
            track = Track.find_or_create_by_title(
              :release => release,
              :fingerprint => generate_fingerprint(file),
              :title => track_title,
              :track_nr => track_nr,
              :length => mp3info.length,
              :bitrate => mp3info.bitrate,
              :samplerate => mp3info.samplerate,
              :vbr => mp3info.vbr,
              :content_type => 'audio/mpeg',
              :size => file.size,
              :file => file)
            unless track.valid?
              logger.error(track.errors.full_messages.to_sentence)
            end
          end
        end
        
        AWS::S3::S3Object.delete(options[:key], options[:bucket])
      end
    end
    
    def generate_fingerprint(file)
      Digest::SHA1.hexdigest(file.open.read)
    end
    
    def parse_filename(original_filename)
      filename = File.basename(original_filename,
                               File.extname(original_filename))
      track_nr = filename.match(/([0-9]+)[ -_]/).to_a.last
      parts = filename.split('-')
      parts = parts.size > 3 ? [parts[0],parts[1],parts[2..-1].join('-')] : parts
      parts = parts.map(&:humanize).map(&:strip).map(&:titleize)
      {
        :track_nr => track_nr,
        :title => parts.last.present? ? parts.last : unknown_title,
        :artist => parts.size > 1 && parts[0] != track_nr ? parts[0] :
                                                            unknown_artist,
        :release => parts.size > 2 &&  parts[1] != track_nr ? parts[1] :
                                                              unknown_release
      }
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
