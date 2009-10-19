class Label < ActiveRecord::Base
  
  has_many :releases
  has_many :artists, :through => :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :mbid
  validates_presence_of :name
  
  default_scope :order => 'name'
  
end
