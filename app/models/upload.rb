class Upload < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :key
  validates_presence_of :bucket

  cattr_accessor :unknown_artist
  self.unknown_artist = '[Unknown Artist]'

  cattr_accessor :unknown_release
  self.unknown_release = '[Unknown Release]'

  cattr_accessor :unknown_title
  self.unknown_title = '[Unknown Title]'

  cattr_accessor :various_artists
  self.various_artists = 'Various Artists'

  def perform
    import && destroy
  end

  def import
    download do |file|
      logger.info("Importing #{key} from #{bucket}")
      
      Mp3Info.open(file.path, :encoding => 'utf-8') do |mp3info|
        
        track_artist_name = 
          mp3info.tag.artist.blank? ? 
            self.class.parse_filename(key)[:artist] : mp3info.tag.artist
        if mp3info.tag2['TCMP'] == '1'
          album_artist_name = mp3info.tag2['TPE2'].present? ? 
            mp3info.tag2['TPE2'] : various_artists
        else
          album_artist_name = track_artist_name
        end
        release_title = 
          mp3info.tag.album.blank? ? 
            self.class.parse_filename(key)[:release] : mp3info.tag.album
        release_year = 
          mp3info.tag.year.blank? ? 
            self.class.parse_filename(key)[:year] : mp3info.tag.year
        track_title = 
          mp3info.tag.title.blank? ? 
            self.class.parse_filename(key)[:title] : mp3info.tag.title
        track_nr =
          mp3info.tag.tracknum.blank? ?
            self.class.parse_filename(key)[:track_nr] : mp3info.tag.tracknum
        
        logger.info("Title: #{track_title}")
        logger.info("Artist: #{track_artist_name}")
        logger.info("Album artist: #{album_artist_name}")
        logger.info("Release: #{release_title}")
        logger.info("Year: #{release_year}")
        logger.info("Track No.: #{track_nr}")
        logger.info("Length: #{mp3info.length}")
        logger.info("Bitrate: #{mp3info.bitrate}")
        logger.info("Sample rate: #{mp3info.samplerate}")
        logger.info("VBR: #{mp3info.vbr}")
        
        transaction do
          if track_artist_name != album_artist_name
            track_artist = user.artists.find_or_create_by_name(track_artist_name)
            unless track_artist.valid?
              logger.error(track_artist.errors.full_messages.to_sentence)
              raise
            end
          end
          album_artist = user.artists.find_or_create_by_name(album_artist_name)
          unless album_artist.valid?
            logger.error(album_artist.errors.full_messages.to_sentence)
            raise
          end
          release = album_artist.releases.find_or_create_by_title(
            :user => user,
            :artist => album_artist,
            :title => release_title,
            :year => release_year,
            :artwork => self.class.image_from_id3(mp3info))
          unless release.valid?
            logger.error(release.errors.full_messages.to_sentence)
            raise
          end
          track = release.tracks.find_or_create_by_title(
            :user => user,
            :artist => track_artist,
            :release => release,
            :fingerprint => self.class.generate_fingerprint(file.path,
              mp3info.audio_content.first, mp3info.audio_content.last),
            :title => track_title,
            :track_nr => track_nr,
            :length => mp3info.length,
            :bitrate => mp3info.bitrate,
            :samplerate => mp3info.samplerate,
            :vbr => mp3info.vbr,
            :content_type => 'audio/mpeg',
            :size => file.size,
            :file => file)
          unless track.valid?
            logger.error(track.errors.full_messages.to_sentence)
            raise
          end
        end
      end
    end
    return true
  end

  def download(&block)
    require 'tempfile'
    Tempfile.open('upload', File.join(Rails.root, 'tmp')) do |file|
      AWS::S3::Base.establish_connection!(
        :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'])
      AWS::S3::S3Object.stream(key, bucket) do |chunk|
        file.write(chunk)
      end
      yield(file)
    end
  end

  def before_destroy
    AWS::S3::S3Object.delete(key, bucket)
  end

  class <<self
    def generate_fingerprint(filename, position, length)
      File.open(filename) do |f|
        f.seek(position)
        Digest::SHA1.hexdigest(file.read(length))
      end
    end

    def parse_filename(original_filename)
      filename = File.basename(original_filename,
                               File.extname(original_filename))
      track_nr = filename.match(/([0-9]+)[ -_]/).to_a.last
      parts = filename.split('-')
      parts = parts.size > 3 ? [parts[0],parts[1],parts[2..-1].join('-')] : parts
      parts = parts.map(&:humanize).map(&:strip).map(&:titleize)
      {
        :track_nr => track_nr,
        :title => parts.last.present? ? parts.last : unknown_title,
        :artist => parts.size > 1 && parts[0] != track_nr ? parts[0] :
                                                            unknown_artist,
        :release => parts.size > 2 &&  parts[1] != track_nr ? parts[1] :
                                                              unknown_release
      }
    end

    def image_from_id3(mp3info)
      if mp3info.tag2['APIC']
        nil # StringIO.new(mp3info.tag2['APIC'])
      end
    end
  end

end
