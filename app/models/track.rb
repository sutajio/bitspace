class Track < ActiveRecord::Base
  
  belongs_to :release
  belongs_to :artist
  
  validates_presence_of :release_id
  validates_presence_of :mbid
  validates_presence_of :title
  validates_presence_of :track_nr
  validates_presence_of :length
  validates_presence_of :url
  validates_presence_of :size
  
  validates_uniqueness_of :mbid
  validates_uniqueness_of :track_nr, :scope => [:release_id]
  
  default_scope :order => 'track_nr'
  
end
