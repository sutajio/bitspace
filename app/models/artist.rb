class Artist < ActiveRecord::Base
  
  belongs_to :user
  has_many :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:user_id]
  
  default_scope :order => 'name'
  named_scope :by_name, lambda { |name| { :conditions => { :name => name } } }
  named_scope :with_releases, :conditions => ['releases_count > 0']
  
  searchable_on :name
  
  has_attached_file :artwork,
    :path => ":class/:attachment/:style/:id_partition-:unix_timestamp.png",
    :styles => { :small => ["125x125#", :png], :large => ["500x350", :png] },
    :whiny => false,
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    },
    :default_url => '/images/cover-art.png',
    :url => ":s3_alias_url",
    :s3_host_alias => ENV['CDN_HOST'],
    :bucket => ENV['S3_BUCKET'],
    :s3_headers => {
      'cache-control' => "max-age=#{10.years.to_i}",
      'expires' => 10.years.from_now.utc.httpdate
    }
  
  def update_meta_data
    identify_mbid unless mbid
    fetch_artwork unless artwork.file?
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
  
  def fetch_artwork
    return if name == Upload.various_artists
    with_lastfm do |info|
      if info['image'].present? && info['image'].last['#text'].present?
        self.artwork = open(info['image'].last['#text']) rescue artwork
        self.save!
      end
    end
  end
  
  def merge!(other)
    transaction do
      Track.update_all("artist_id = #{self.id}", "artist_id = #{other.id}")
      other.releases.each do |release|
        my_release = self.releases.find_by_title(release.title)
        if my_release
          my_release.merge!(release)
        else
          release.artist = self
          release.save
        end
      end
      other.reload
      other.destroy
      self.touch
    end
    self
  end
  
  def biography
    with_lastfm do |info|
      return info['bio']['content'] unless info['bio'].blank?
    end
  end
  
  def reprocess_artwork!
    self.artwork.reprocess!
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  protected
  
    def with_lastfm(&block)
      Scrobbler2::Base.api_key = ENV['LASTFM_API_KEY']
      lastfm_artist = Scrobbler2::Artist.new(name)
      if lastfm_artist.info
        yield(lastfm_artist.info)
      end
    end
  
end
