class Artist < ActiveRecord::Base
  
  has_many :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :name
  
  validates_uniqueness_of :name
  validates_uniqueness_of :mbid, :allow_nil => true
  
  default_scope :order => 'name'
  named_scope :by_name, lambda { |name| { :conditions => { :name => name } } }
  
  searchable_on :name
  
  def to_param
    name.tr(' ','+').sub('/','%2F').sub('?','%3F')
  end
  
  class <<self
    def find(*args)
      if args.size == 1 && args.first.respond_to?(:to_str)
        by_name(args.first.tr('+',' ').sub('%2F','/')).first or raise ActiveRecord::RecordNotFound
      else
        super
      end
    end
  end
  
  def update_meta_data
    lastfm_artist = Scrobbler::Artist.new(name)
    self.mbid = lastfm_artist.mbid if lastfm_artist.mbid.present?
    discogs_artist = Discogs::Artist.new(name)
    self.releases.find(:all, :conditions => { :title => discogs_artist.releases.map(&:title) }).each do |release|
      discogs_release = discogs_artist.releases.find {|r| r.title == release.title }
      release.label = Label.find_or_create_by_name(discogs_release.labels.first) if discogs_release.labels.present?
      release.artwork = open(discogs_release.images.first.uri) if discogs_release.images.first.try(:uri)
      release.save!
    end
    self.save!
  end
  
  after_create :update_meta_data
  handle_asynchronously :update_meta_data if Rails.env.production?
  
end
