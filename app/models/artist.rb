class Artist < ActiveRecord::Base
  
  belongs_to :user
  has_many :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:user_id]
  
  default_scope :order => 'name'
  named_scope :by_name, lambda { |name| { :conditions => { :name => name } } }
  named_scope :with_releases, :conditions => ['releases_count > 0']
  
  searchable_on :name
  
  def to_param(double_encode_if_nessecary = true)
    name.include?('+') && double_encode_if_nessecary ?
      CGI.escape(CGI.escape(name).sub('.','%2E')) :
      CGI.escape(name).sub('.','%2E')
  end
  
  class <<self
    def find(*args)
      if args.first.is_a?(String) && args.first.to_i.to_s != args.first
        with_scope(:find => args.size == 2 ? args.last : {}) do
          by_name(CGI.unescape(args.first)).first or raise ActiveRecord::RecordNotFound
        end
      else
        super
      end
    end
  end
  
  def update_meta_data
    lastfm_artist = Scrobbler::Artist.new(name)
    self.mbid = lastfm_artist.mbid if lastfm_artist.mbid.present?
    discogs_artist = Discogs::Artist.new(name)
    discogs_releases = discogs_artist.releases.map do |r|
      r.title rescue OpenURI::HTTPError
      r
    end
    self.releases.find(:all, :conditions => { :title => discogs_releases.map(&:title) }).each do |release|
      discogs_release = discogs_releases.find {|r| r.title == release.title }
      if discogs_release.labels.present?
        release.label = Label.find_or_create_by_name_and_user_id(:name => discogs_release.labels.first, :user_id => user.id)
      end
      unless release.artwork.file?
        release.artwork = open(discogs_release.images.first.uri) if discogs_release.images.first.try(:uri)
      end
      release.save!
    end
    self.save!
  rescue OpenURI::HTTPError => e
    if e.io.status[0] == '404'
      return true
    else
      raise
    end
  end
  
  after_create :update_meta_data unless Rails.env.test?
  handle_asynchronously :update_meta_data if Rails.env.production?
  
end
