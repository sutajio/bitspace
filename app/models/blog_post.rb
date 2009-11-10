class BlogPost < ActiveRecord::Base
  
  validates_presence_of :title
  validates_presence_of :slug
  validates_presence_of :year
  validates_presence_of :month
  validates_uniqueness_of :slug, :scope => [:year,:month]

  default_scope :order => 'created_at'
  named_scope :published, :conditions => { :published => true }
  
  def generate_permalink
    self.slug = CGI.escape(title.downcase).gsub('+','-')
    self.year = Time.now.year
    self.month = Time.now.month
  end
  
  before_validation_on_create :generate_permalink

end
