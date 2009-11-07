class Label < ActiveRecord::Base
  
  belongs_to :user
  has_many :releases
  has_many :artists, :through => :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:user_id]
  
  default_scope :order => 'name'
  
  searchable_on :name
  
  def update_meta_data
  rescue OpenURI::HTTPError => e
    if e.io.status[0] == '404'
      return true
    else
      raise
    end
  end
  
  after_create :update_meta_data
  handle_asynchronously :update_meta_data if Rails.env.production?
  
end
