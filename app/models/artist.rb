class Artist < ActiveRecord::Base
  
  has_many :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :mbid
  validates_presence_of :name
  
  validates_uniqueness_of :mbid
  
  default_scope :order => 'name'
  
end
