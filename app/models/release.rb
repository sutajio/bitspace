class Release < ActiveRecord::Base
  
  belongs_to :artist
  belongs_to :label
  has_many :tracks
  
  validates_presence_of :artist_id
  validates_presence_of :title
  
  validates_uniqueness_of :mbid, :allow_nil => true
  
  default_scope :order => 'year DESC'
  
  searchable_on :title, :year
  
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
