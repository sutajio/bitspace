class Track < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :release
  belongs_to :artist
  
  has_many :playlist_items
  
  validates_presence_of :user_id
  validates_presence_of :release_id
  validates_presence_of :fingerprint
  validates_presence_of :title
  validates_presence_of :length
  validates_presence_of :size
  validates_uniqueness_of :track_nr, :scope => [:release_id], :allow_nil => true
  
  default_scope :order => 'track_nr'
  
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
  
  def update_meta_data
    track = Scrobbler::Track.new(artist ? artist.name : release.artist.name, title)
    self.mbid = track.mbid if track.mbid.present?
    self.save!
  end
  
  after_create :update_meta_data
  handle_asynchronously :update_meta_data if Rails.env.production?
  
  def toggle_love!
    loved? ? unlove! : love!
  end
  
  def love!
    playlist_items.create(:user_id => user_id)
  end
  
  def unlove!
    playlist_items.all.each(&:destroy)
  end
  
  def loved?
    playlist_items.present?
  end
  
end
