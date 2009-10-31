class Release < ActiveRecord::Base
  
  belongs_to :artist, :counter_cache => true
  belongs_to :label
  has_many :tracks
  
  validates_presence_of :artist_id
  validates_presence_of :title
  
  validates_uniqueness_of :title, :scope => [:artist_id]
  validates_uniqueness_of :mbid, :allow_nil => true
  
  default_scope :order => 'year DESC'
  named_scope :by_year, lambda {|year| { :conditions => { :year => year } } }
  
  def self.first_with_artwork
    first(:order => 'artwork_updated_at IS NOT NULL DESC, artwork_updated_at DESC')
  end
  
  scoped_search :on => [:title]
  scoped_search :in => :artist, :on => [:name]
  scoped_search :in => :tracks, :on => [:title]
  
  has_attached_file :artwork,
    :path => ":class/:attachment/:style/:id_partition.png",
    :styles => { :medium => ["500x500>", :png], :small => ["125x125#", :png] },
    :whiny => false,
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    },
    :default_url => '/images/cover-art.png',
    :url => ":s3_alias_url",
    :s3_host_alias => ENV['CDN_HOST'],
    :bucket => ENV['S3_BUCKET']
  
  def update_meta_data
    require 'open-uri'
    album = Scrobbler::Album.new(artist.name, title, :include_info => true)
    unless self.artwork.file?
      if album.image_large.present? && !album.image_large.include?('default')
        self.artwork = open(album.image_large)
      end
    end
    self.mbid = album.mbid if album.mbid.present?
    if album.release_date.present? && !album.release_date.today?
      self.year = album.release_date.year
    end
    self.save!
  end
  
  after_create :update_meta_data
  handle_asynchronously :update_meta_data if Rails.env.production?
end
