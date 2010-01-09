class Client < ActiveRecord::Base
  
  has_many :client_versions
  
  validates_presence_of :name
  validates_presence_of :slug
  validates_presence_of :info
  validates_uniqueness_of :name
  validates_uniqueness_of :slug
  
  def generate_slug
    self.slug ||= name.parameterize
  end
  
  before_validation_on_create :generate_slug
  
  def downloads
    client_versions.sum(:downloads)
  end
  
  def to_param
    slug
  end
  
end
