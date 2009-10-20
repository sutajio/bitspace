class Artist < ActiveRecord::Base
  
  has_many :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :name
  
  validates_uniqueness_of :mbid, :allow_nil => true
  
  default_scope :order => 'name'
  named_scope :by_name, lambda { |name| { :conditions => { :name => name } } }
  
  searchable_on :name
  
  def to_param
    name.tr(' ','+')
  end
  
  class <<self
    def find(*args)
      if args.size == 1 && args.first.respond_to?(:to_str)
        by_name(args.first.tr('+',' ')).first or raise RecordNotFound
      else
        super
      end
    end
  end
  
end
