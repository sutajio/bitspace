class Release < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :artist, :counter_cache => true
  belongs_to :label
  has_many :tracks, :dependent => :destroy
  
  validates_presence_of :user_id
  validates_presence_of :artist_id
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => [:artist_id]
  
  default_scope :order => 'year DESC, release_date DESC', :include => [:artist]
  named_scope :by_year, lambda {|year| { :conditions => { :year => year } } }
  named_scope :with_archived, :conditions => { :archived => [true, false] }
  named_scope :without_archived, :conditions => { :archived => false }
  
  def self.first_with_artwork
    first(:order => 'artwork_updated_at IS NOT NULL DESC, artwork_updated_at DESC')
  end
  
  scoped_search :on => [:title]
  scoped_search :in => :artist, :on => [:name]
  scoped_search :in => :tracks, :on => [:title]
  
  has_attached_file :artwork,
    :path => ":class/:attachment/:style/:id_partition-:unix_timestamp.png",
    :styles => { :large => ["500x500>", :png], :small => ["125x125#", :png] },
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
    require 'open-uri'
    sleep(2.seconds.to_i)
    album = Scrobbler::Album.new(artist.name, title, :include_info => true)
    unless self.artwork.file?
      if album.image_large.present? && !album.image_large.include?('default')
        self.artwork = open(album.image_large)
      end
    end
    self.mbid = album.mbid if album.mbid.present?
    if album.release_date.present? && !album.release_date.today?
      self.year ||= album.release_date.year
      self.release_date ||= album.release_date
    end
    self.save!
  rescue OpenURI::HTTPError => e
    if e.io.status[0] == '404'
      return true
    else
      raise
    end
  end
  
  after_create :update_meta_data unless Rails.env.test?
  handle_asynchronously :update_meta_data
  
  def toggle_archive!
    archived? ? unarchive! : archive!
  end
  
  def archive!
    update_attribute(:archived, true)
  end
  
  def unarchive!
    update_attribute(:archived, false)
  end
  
end
