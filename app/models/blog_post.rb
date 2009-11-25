class BlogPost < ActiveRecord::Base
  
  validates_presence_of :title
  validates_presence_of :slug
  validates_presence_of :year
  validates_presence_of :month
  validates_uniqueness_of :slug, :scope => [:year,:month]

  default_scope :order => 'created_at DESC'
  named_scope :published, :conditions => { :published => true }
  
  def generate_permalink
    self.slug = title.parameterize
    self.year = Time.now.year
    self.month = Time.now.month
  end
  
  before_validation_on_create :generate_permalink

end
