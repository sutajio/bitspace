class Artist < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :original, :class_name => 'Artist'
  has_many :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:user_id]
  
  scope :by_name, lambda { |name| { :conditions => { :name => name } } }
  scope :with_archived, :conditions => { :archived => [true, false] }
  scope :without_archived, :conditions => { :archived => false }
  scope :has_releases, :conditions => ['releases_count > 0']
  
  def self.first_with_artwork
    first(:order => 'artists.artwork_updated_at IS NOT NULL DESC, artists.artwork_updated_at DESC')
  end
  
  searchable_on :name
  
  has_attached_file :artwork,
    :path => ":class/:attachment/:style/:id_partition-:unix_timestamp.png",
    :styles => { :small => ["125x125#", :png], :large => ["500x350", :png] },
    :whiny => false,
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    },
    :default_url => '/images/artwork-small.jpg',
    :url => ":s3_alias_url",
    :s3_host_alias => ENV['CDN_HOST'],
    :bucket => ENV['S3_BUCKET'],
    :s3_headers => {
      'cache-control' => "max-age=#{10.years.to_i}",
      'expires' => 10.years.from_now.utc.httpdate
    }
  
  def update_meta_data
    identify_mbid unless mbid
    fetch_artwork unless artwork.file?
    update_sort_name
    update_artist_type unless artist_type
    update_dates unless begin_date && end_date
    update_website unless website
    update_tags unless tags
  end
  
  after_create :update_meta_data unless Rails.env.test?
  handle_asynchronously :update_meta_data
  
  def identify_mbid
    with_lastfm do |info|
      if info['mbid'].present?
        self.mbid = info['mbid']
        self.save!
      end
    end
  end
  
  def fetch_artwork
    return if name == Upload.various_artists
    with_lastfm do |info|
      if info['image'].present? && info['image'].last['#text'].present?
        self.artwork = open(info['image'].last['#text']) rescue artwork
        self.save!
      end
    end
  end
  
  def merge!(other)
    transaction do
      Track.update_all("artist_id = #{self.id}", "artist_id = #{other.id}")
      other.releases.each do |release|
        my_release = self.releases.find_by_title(release.title)
        if my_release
          my_release.merge!(release)
        else
          release.artist = self
          release.save
        end
      end
      other.reload
      other.destroy
      self.touch
    end
    self
  end
  
  def biography
    if read_attribute(:biography)
      read_attribute(:biography)
    else
      with_lastfm do |info|
        return nil if info['bio'].blank?
        bio = info['bio']['content']
        update_attribute(:biography, bio)
        bio
      end
    end
  end
  
  def reprocess_artwork!
    self.artwork.reprocess!
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def update_sort_name
    with_music_brainz do |info|
      if info.sort_name.present?
        self.sort_name = info.sort_name
      end
    end
    self.sort_name ||= "#{name[4..-1]}, The" if name.match(/^The /)
    self.sort_name ||= name
    self.sort_name = self.sort_name.anal_title_case
    self.save!
  end
  
  def update_artist_type
    with_music_brainz do |info|
      if info.type.present?
        case info.type
        when MusicBrainz::Model::Artist::TYPE_PERSON:
          self.artist_type = 'Person'
        when MusicBrainz::Model::Artist::TYPE_GROUP:
          self.artist_type = 'Group'
        end
        self.save!
      end
    end
  end
  
  def update_dates
    with_music_brainz do |info|
      self.begin_date = info.begin_date.first if info.begin_date
      self.end_date = info.end_date.last if info.end_date
      self.save!
    end
  end
  
  def update_website
    with_music_brainz(:url_rels => true) do |info|
      urls = info.get_relations(:target_type => MusicBrainz::Model::Relation::TO_URL,
                                :relation_type => MusicBrainz::Model::NS_REL_1 + 'OfficialHomepage')
      if urls.present?
        self.website = urls.sort_by(&:begin_date).last.target
        self.save!
      end
    end
  end
  
  def update_tags
    with_music_brainz(:tags => true) do |info|
      self.tags = info.tags.map(&:text).join(', ')[0..254] if info.tags.present?
      self.save!
    end
  end
  
  def copy(to_user)
    artwork_file = artwork.file? ? open(artwork.url) : nil rescue nil
    artist = to_user.artists.find_or_create_by_name(
      :name => name,
      :artwork => artwork_file,
      :mbid => mbid,
      :tags => tags,
      :sort_name => sort_name,
      :artist_type => artist_type,
      :begin_date => begin_date,
      :end_date => end_date,
      :website => website,
      :tags => tags,
      :original => self)
    unless artist.valid?
      logger.error(artist.errors.full_messages.to_sentence)
      raise artist.errors.full_messages.to_sentence
    end
    artist
  end
  
  def toggle_archive!
    archived? ? unarchive! : archive!
  end
  
  def archive!
    update_attribute(:archived, true)
  end
  
  def unarchive!
    update_attribute(:archived, false)
  end
  
  protected
  
    def with_lastfm(&block)
      Scrobbler2::Base.api_key = ENV['LASTFM_API_KEY']
      lastfm_artist = Scrobbler2::Artist.new(name)
      if lastfm_artist.info
        yield(lastfm_artist.info)
      end
    end
    
    def with_music_brainz(options = {}, &block)
      if @musicbrainz_artist && options == {}
        yield(@musicbrainz_artist)
      else
        if mbid
          sleep(2)
          q = MusicBrainz::Webservice::Query.new
          @musicbrainz_artist = q.get_artist_by_id(mbid, options)
          if @musicbrainz_artist
            yield(@musicbrainz_artist)
          end
        end
      end
    end
  
end
