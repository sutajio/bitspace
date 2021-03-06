class Release < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :original, :class_name => 'Release'
  belongs_to :artist, :counter_cache => true
  has_many :tracks, :dependent => :destroy
  has_many :comments, :dependent => :destroy, :as => :commented
  
  validates_presence_of :user_id
  validates_presence_of :artist_id
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => [:artist_id]
  
  default_scope :order => 'year DESC, release_date DESC'
  named_scope :by_year, lambda {|year| { :conditions => { :year => year } } }
  named_scope :with_archived, :conditions => { :archived => [true, false] }
  named_scope :without_archived, :conditions => { :archived => false }
  named_scope :has_tracks, :conditions => ['tracks_count > 0']
  named_scope :updated_since, lambda {|date| date.present? ? { :conditions => ['releases.updated_at > ?', date.is_a?(String) ? Time.parse(date) : date] } : {} }
  
  def self.first_with_artwork
    first(:order => 'artwork_updated_at IS NOT NULL DESC, artwork_updated_at DESC')
  end
  
  scoped_search :on => [:title, :year, :tags, :label]
  scoped_search :in => :artist, :on => [:name]
  scoped_search :in => :tracks, :on => [:title]
  
  has_attached_file :artwork,
    :path => ":class/:attachment/:style/:id_partition-:unix_timestamp.png",
    :styles => { :large => ["500x500>", :png], :medium => ["240x240#", :png], :small => ["125x125#", :png] },
    :whiny => false,
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    },
    :default_url => '/images/artwork-large.jpg',
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
          self.label = label.name
          self.save!
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
    transaction do
      update_attribute(:archived, true)
      if self.artist && self.artist.releases.without_archived.empty?
        self.artist.archive!
      end
      if self.label && self.label.releases.without_archived.empty?
        self.label.archive!
      end
    end
  end
  
  def unarchive!
    transaction do
      update_attribute(:archived, false)
      self.artist.unarchive! if self.artist
      self.label.unarchive! if self.label
    end
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
      other.archive!
      self.touch
    end
    self
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
      track.rename(attributes[:title], attributes[:artist],
                   attributes[:track_nr], attributes[:set_nr])
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
  
  def copy(to_artist)
    artwork_file = artwork.file? ? open(artwork.url) : nil rescue nil
    release = to_artist.releases.find_or_create_by_title(
      :user => to_artist.user,
      :artist => to_artist,
      :label => label,
      :title => title,
      :year => year,
      :artwork => artwork_file,
      :mbid => mbid,
      :release_date => release_date,
      :tags => tags,
      :archived => false,
      :original => self)
    unless release.valid?
      logger.error(release.errors.full_messages.to_sentence)
      raise release.errors.full_messages.to_sentence
    end
    release
  end
  
  def sideload(to_user)
    transaction do
      album_artist = artist.copy(to_user)
      release = copy(album_artist)
      tracks.each do |track|
        track.copy(release)
      end
      release
    end
  end
  
  handle_asynchronously :sideload, :priority => 1
  
  def generate_download
    tracks_dir = File.join(Rails.root, 'tmp', "release-#{id}")
    downloaded_tracks = tracks.map do |track|
      track.download(tracks_dir)
    end
    release_filename = File.join(Rails.root, 'tmp', download_key)
    FileUtils.mkdir_p(File.dirname(release_filename))
    FileUtils.chdir(tracks_dir) do
      `zip -r -D "#{release_filename}" #{downloaded_tracks.map{|t| "\"#{File.basename(t)}\"" }.join(' ')}`
    end
    FileUtils.rm_rf(tracks_dir)
    AWS::S3::Base.establish_connection!(
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'])
    File.open(release_filename, 'rb') do |file|
      AWS::S3::S3Object.store(download_key, file, ENV['S3_BUCKET'],
        :access => :private,
        :content_type => 'application/zip',
        'content-disposition' => "attachment;filename=#{download_filename}")
    end
    FileUtils.rm(release_filename)
    download_url
  end
  
  handle_asynchronously :generate_download, :priority => 2
  
  def download_key
    "downloads/#{Digest::MD5.hexdigest("#{id}#{updated_at.iso8601}")}.zip"
  end
  
  def download_url
    AWS::S3::Base.establish_connection!(
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'])
    if AWS::S3::S3Object.exists?(download_key, ENV['S3_BUCKET'])
      AWS::S3::S3Object.url_for(download_key, ENV['S3_BUCKET'], :expires_in => 5.minutes)
    end
  end
  
  def download_filename
    filename = year ? "#{artist.name} - #{title} (#{year}).zip" : "#{artist.name} - #{title}.zip"
    filename.gsub('/','').gsub("\\",'')
  end
  
  def playable?(user)
    self.user == user || (user && user.subscribes_to?(self.user))
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
