class Artist < ActiveRecord::Base
  
  has_many :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :name
  
  validates_uniqueness_of :mbid, :allow_nil => true
  
  default_scope :order => 'name'
  
  searchable_on :name
  
end
