class Label < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :original, :class_name => 'Label'
  has_many :releases
  has_many :artists, :through => :releases
  has_many :tracks, :through => :releases
  
  validates_presence_of :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:user_id]
  
  default_scope :order => 'name'
  
  searchable_on :name
  
  has_attached_file :artwork,
    :path => ":class/:attachment/:style/:id_partition-:unix_timestamp.png",
    :whiny => false,
    :storage => :s3,
    :s3_credentials => {
      :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
    },
    :default_url => '/images/cover-art.jpg',
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
    update_website unless website
  end
  
  after_create :update_meta_data unless Rails.env.test?
  handle_asynchronously :update_meta_data
  
  def identify_mbid
  end
  
  def update_website
    with_discogs do |info|
      if info.urls.present?
        self.website = info.urls.first.squish
        self.save!
      end
    end
  end
  
  def profile
    with_discogs do |info|
      return info.try(:profile)
    end
  end
  
  def fetch_artwork
    with_discogs do |info|
      if info.images.present?
        self.artwork = open(info.images.sort_by(&:type).first.uri ||
                            info.images.sort_by(&:type).first.uri150) rescue artwork
        self.save!
      end
    end
  end
  
  def copy(to_user)
    label = to_user.labels.find_or_create_by_name(
      :user => to_user,
      :name => name,
      :artwork => artwork.file? ? open(artwork.url) : nil,
      :mbid => mbid,
      :website => website,
      :original => self)
    unless label.valid?
      logger.error(label.errors.full_messages.to_sentence)
      raise label.errors.full_messages.to_sentence
    end
    label
  end
  
  protected
  
    def with_discogs(&block)
      @discogs_label ||= Discogs::Label.new(name)
      @discogs_label.name # Try to fetch data
      yield(@discogs_label)
    rescue OpenURI::HTTPError => e
    end
    
    def with_music_brainz(options = {}, &block)
      if mbid
        sleep(2)
        q = MusicBrainz::Webservice::Query.new
        label = q.get_label_by_id(mbid, options)
        if label
          yield(label)
        end
      end
    end
  
end
