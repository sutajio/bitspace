class Track < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :release, :counter_cache => true
  belongs_to :artist
  
  has_many :scrobbles
  
  validates_presence_of :user_id
  validates_presence_of :release_id
  validates_presence_of :fingerprint
  validates_presence_of :title
  validates_presence_of :length
  validates_presence_of :size
  validates_uniqueness_of :fingerprint, :scope => [:release_id, :set_nr]
  
  default_scope :order => 'track_nr'
  named_scope :loved, :conditions => ['loved_at IS NOT NULL']
  
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
    "tracks/#{fingerprint}.#{format}"
  end
  
  def format
    case content_type
    when 'audio/mpeg': 'mp3'
    when 'audio/ogg': 'oga'
    when 'application/ogg': 'ogg'
    when 'audio/x-ms-wma': 'wma'
    when 'audio/mp4': 'm4a'
    when 'application/mp4': 'mp4'
    when 'audio/x-flac': 'flac'
    end
  end
  
  attr_writer :file
  
  def upload_track
    if @file
      unless AWS::S3::S3Object.exists?(key, ENV['S3_BUCKET'])
        AWS::S3::S3Object.store(key, @file, ENV['S3_BUCKET'],
          :content_type => content_type,
          :access => :public_read,
          'cache-control' => "max-age=#{10.years.to_i}",
          'expires' => 10.years.from_now.utc.httpdate)
        logger.info "Key: #{key}"
        return true
      end
    end
  end
  
  before_save :upload_track
  
  def update_meta_data
    identify_mbid unless mbid
  end
  
  after_create :update_meta_data unless Rails.env.test?
  handle_asynchronously :update_meta_data
  
  def identify_mbid
    with_lastfm do |info|
      if info['mbid'].present?
        self.mbid = info['mbid']
        self.save!
      end
    end
  end
  
  def toggle_love!
    loved? ? unlove! : love!
  end
  
  def love!
    touch(:loved_at)
  end
  
  def unlove!
    self.loved_at = nil
    save!
  end
  
  def loved?
    loved_at.present?
  end
  
  def rename(new_title, new_artist = nil)
    if new_title.present?
      self.title = new_title
    end
    if new_artist.present?
      self.artist = user.artists.find_or_create_by_name(new_artist)
    else
      self.artist = nil
    end
    save!
  end
  
  def download(to_directory)
    track_filename = File.join(to_directory, download_filename)
    FileUtils.mkdir_p(File.dirname(track_filename))
    `curl -o "#{track_filename}" "#{url(false)}"`
    track_filename
  end
  
  def download_filename
    filename = set_nr ? "#{"%02d" % set_nr.to_i} - #{"%02d" % track_nr.to_i} - #{title}.#{format}" :
                        "#{"%02d" % track_nr.to_i} - #{title}.#{format}"
    filename.gsub('/','').gsub("\\",'')
  end
  
  protected
  
    def with_lastfm(&block)
      Scrobbler2::Base.api_key = ENV['LASTFM_API_KEY']
      lastfm_track = Scrobbler2::Track.new(artist ? artist.name : release.artist.name, title)
      if lastfm_track.info
        yield(lastfm_track.info)
      end
    end
  
end
