class Release < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :artist, :counter_cache => true
  belongs_to :label, :counter_cache => true
  has_many :tracks, :dependent => :destroy
  
  validates_presence_of :user_id
  validates_presence_of :artist_id
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => [:artist_id]
  
  default_scope :order => 'year DESC, release_date DESC', :include => [:artist]
  named_scope :by_year, lambda {|year| { :conditions => { :year => year } } }
  named_scope :with_archived, :conditions => { :archived => [true, false] }
  named_scope :without_archived, :conditions => { :archived => false }
  
  def self.first_with_artwork
    first(:order => 'artwork_updated_at IS NOT NULL DESC, artwork_updated_at DESC')
  end
  
  scoped_search :on => [:title, :year, :tags]
  scoped_search :in => :artist, :on => [:name]
  scoped_search :in => :tracks, :on => [:title]
  scoped_search :in => :label, :on => [:name]
  
  has_attached_file :artwork,
    :path => ":class/:attachment/:style/:id_partition-:unix_timestamp.png",
    :styles => { :large => ["500x500>", :png], :medium => ["240x240#", :png], :small => ["125x125#", :png] },
    :whiny => false,
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    },
    :default_url => '/images/cover-art.png',
    :url => ":s3_alias_url",
    :s3_host_alias => ENV['CDN_HOST'],
    :bucket => ENV['S3_BUCKET'],
    :s3_headers => {
      'cache-control' => "max-age=#{10.years.to_i}",
      'expires' => 10.years.from_now.utc.httpdate
    }
  
  def update_meta_data
    identify_mbid unless mbid
    update_release_date unless release_date
    update_label unless label
    update_tags unless tags
    fetch_artwork unless artwork.file?
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
  
  def update_release_date
    with_lastfm do |info|
      now = Time.now
      date = Time.parse(info['releasedate'].strip, now)
      if date != now
        self.release_date = date
        self.year = date.year
        self.save!
      end
    end
  end
  
  def update_label
    with_music_brainz :release_events => true, :labels => true do |release|
      if release.release_events.present?
        label = release.release_events[0].label
        if label
          transaction do
            self.label = Label.find_or_create_by_name_and_user_id(
                                :name => label.name, :user_id => user.id)
            self.save!
            self.label.try(:touch)
          end
        end
      end
    end
  end
  
  def update_tags
    with_music_brainz :tags => true do |release|
      self.tags = release.tags.map(&:text).join(', ')[0..254] if release.tags.present?
      self.save!
    end
  end
  
  def fetch_artwork
    with_lastfm do |info|
      if info['image'].present? && info['image'].last['#text'].present?
        self.artwork = open(info['image'].last['#text']) rescue artwork
        self.save!
      end
    end
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
  
  def reprocess_artwork!
    self.artwork.reprocess!
  end
  
  def merge!(other)
    transaction do
      other.tracks.each do |track|
        track.release = self
        track.save
      end
      other.reload
      other.destroy
      self.touch
    end
    self
  end
  
  def notify_followers
    if user.public_profile?
      user.followers.each do |follower|
        follower.notify_of_new_release(self)
      end
    end
  end
  
  after_create :notify_followers unless Rails.env.test?
  handle_asynchronously :notify_followers
  
  def review
  end
  
  def buy_links
    []
  end
  
  def to_param
    "#{id}-#{artist.name.parameterize}-#{title.parameterize}"
  end
  
  def rename(new_name)
    other_release = artist.releases.find_by_title(new_name)
    if other_release && other_release != self
      other_release.merge!(self)
      other_release
    else
      self.update_attributes!(:title => new_name)
      self
    end
  end
  
  def rename_artist(new_artist_name)
    artist = user.artists.find_or_create_by_name(new_artist_name)
    other_release = artist.releases.find_by_title(title)
    if other_release && other_release != self
      other_release.merge!(self)
      other_release
    else
      old_artist = self.artist
      self.artist = artist
      self.save!
      old_artist.touch
      artist.touch
      self
    end
  end
  
  def rename_tracks(new_track_names)
    new_track_names.each do |id,attributes|
      track = tracks.find_by_id(id)
      track.rename(attributes[:title], attributes[:artist])
    end
  end
  
  def change_year(new_year)
    self.year = new_year.to_i == 0 ? nil : new_year.to_i.abs
    self.save!
  end
  
  def could_be_various_artists?
    mbid.blank? &&
    title != Upload.unknown_release &&
    !title.match(/greatest hits/i) &&
    !title.match(/ ep$/i) &&
    !title.match(/ (ep)$/i) &&
    !title.match(/ [ep]$/i) &&
    tracks_count > 0 &&
    tracks_count <= 5
  end
  
  def has_track_with_nr?(set_nr, track_nr)
    return false if track_nr.nil?
    if set_nr.nil?
      return true if tracks.find_by_track_nr(track_nr.to_i)
    else
      return true if tracks.find_by_set_nr_and_track_nr(set_nr.to_i, track_nr.to_i)
    end
  end
  
  def copy(to_user)
    transaction do
      album_artist = to_user.artists.find_or_create_by_name(self.artist.name)
      unless album_artist.valid?
        logger.error(album_artist.errors.full_messages.to_sentence)
        raise album_artist.errors.full_messages.to_sentence
      end
      release = to_user.releases.find_or_create_by_title(
        :user => to_user,
        :artist => album_artist,
        :title => self.title,
        :year => self.year,
        :artwork => self.artwork.file? ? open(self.artwork.url).read : nil)
      unless release.valid?
        logger.error(release.errors.full_messages.to_sentence)
        raise release.errors.full_messages.to_sentence
      end
      self.tracks.each do |track|
        if track.artist
          track_artist = to_user.artists.find_or_create_by_name(track.artist.name)
        else
          track_artist = nil
        end
        release.tracks.find_or_create_by_fingerprint(
          :user => to_user,
          :artist => track_artist,
          :release => release,
          :fingerprint => track.fingerprint,
          :title => track.title,
          :track_nr => track.track_nr,
          :set_nr => track.set_nr,
          :length => track.length,
          :bitrate => track.bitrate,
          :samplerate => track.samplerate,
          :vbr => track.vbr,
          :content_type => track.content_type,
          :size => track.size)
      end
      release
    end
  end
  
  protected
  
    def with_lastfm(&block)
      Scrobbler2::Base.api_key = ENV['LASTFM_API_KEY']
      lastfm_album = Scrobbler2::Album.new(artist.name, title)
      if lastfm_album.info
        yield(lastfm_album.info)
      end
    end
    
    def with_music_brainz(options = {}, &block)
      if mbid
        sleep(2)
        q = MusicBrainz::Webservice::Query.new
        release = q.get_release_by_id(mbid, options)
        if release
          yield(release)
        end
      end
    end
  
end
