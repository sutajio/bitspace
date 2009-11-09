class BlogPost < ActiveRecord::Base

  default_scope :order => 'created_at'
  named_scope :published, :conditions => { :published => true }

  def to_param
    "#{id}-#{CGI.escape(title.downcase).gsub('+','-')}"
  end

end
