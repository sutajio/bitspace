class Release < ActiveRecord::Base
  
  belongs_to :artist
  belongs_to :label
  has_many :tracks
  
  validates_presence_of :artist_id
  validates_presence_of :title
  validates_presence_of :year
  
  validates_uniqueness_of :mbid, :allow_nil => true
  
  default_scope :order => 'year DESC'
  
  searchable_on :title, :year
  
end
