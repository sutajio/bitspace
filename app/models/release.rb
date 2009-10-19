class Album < ActiveRecord::Base
  
  belongs_to :artist
  belongs_to :label
  has_many :tracks
  
  validates_presence_of :artist_id
  validates_presence_of :mbid
  validates_presence_of :title
  validates_presence_of :year
  
  validates_uniqueness_of :mbid
  
  default_scope :order => 'year DESC'
  
end
