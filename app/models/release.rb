class Release < ActiveRecord::Base
  
  belongs_to :artist
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
  
end
