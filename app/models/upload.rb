class Upload < ActiveRecord::Base

  belongs_to :user

  validates_presence_of :key

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
      logger.info("Importing #{key} from #{bucket || 'the interwebs'}")
      
      require 'audioinfo/audioinfo'
      
      AudioInfo.open(file.path, :extension => File.extname(key)[1..-1],
                                :encoding => 'utf-8') do |tags|
        
        track_artist_name = 
          tags.artist.blank? ? 
            self.class.parse_filename(key)[:artist] : tags.artist
        if tags.compilation?
          album_artist_name = tags.album_artist.present? ? 
            tags.album_artist : various_artists
        else
          album_artist_name = track_artist_name
        end
        release_title = 
          tags.album.blank? ? 
            self.class.parse_filename(key)[:release] : tags.album
        release_year = 
          tags.year.blank? ? 
            self.class.parse_filename(key)[:year] : tags.year
        track_title = 
          tags.title.blank? ? 
            self.class.parse_filename(key)[:title] : tags.title
        track_nr =
          tags.tracknum.blank? ?
            self.class.parse_filename(key)[:track_nr] : tags.tracknum
        track_set_nr =
          tags.setnum.blank? ?
            self.class.parse_filename(key)[:set_nr] : tags.setnum
        
        track_artist_name = track_artist_name.anal_title_case
        album_artist_name = album_artist_name.anal_title_case
        release_title = release_title.anal_title_case
        track_title = track_title.anal_title_case
        
        logger.info("Title: #{track_title}")
        logger.info("Artist: #{track_artist_name}")
        logger.info("Album artist: #{album_artist_name}")
        logger.info("Release: #{release_title}")
        logger.info("Year: #{release_year}")
        logger.info("Track No.: #{track_nr}")
        logger.info("Track Set No.: #{track_set_nr}")
        logger.info("Length: #{tags.length}")
        logger.info("Bitrate: #{tags.bitrate}")
        logger.info("Sample rate: #{tags.samplerate}")
        logger.info("VBR: #{tags.vbr}")
        
        transaction do
          if track_artist_name != album_artist_name
            track_artist = user.artists.find_or_create_by_name(track_artist_name)
            unless track_artist.valid?
              logger.error(track_artist.errors.full_messages.to_sentence)
              raise track_artist.errors.full_messages.to_sentence
            end
          end
          album_artist = user.artists.find_or_create_by_name(album_artist_name)
          unless album_artist.valid?
            logger.error(album_artist.errors.full_messages.to_sentence)
            raise album_artist.errors.full_messages.to_sentence
          end
          release = album_artist.releases.find_or_create_by_title(
            :user => user,
            :artist => album_artist,
            :title => release_title,
            :year => release_year,
            :artwork => tags.cover)
          unless release.valid?
            logger.error(release.errors.full_messages.to_sentence)
            raise release.errors.full_messages.to_sentence
          end
          track = release.tracks.find_or_create_by_title_and_track_nr(
            :user => user,
            :artist => track_artist,
            :release => release,
            :fingerprint => self.class.generate_fingerprint(tags.audio_content),
            :title => track_title,
            :track_nr => track_nr,
            :set_nr => track_set_nr,
            :length => tags.length,
            :bitrate => tags.bitrate,
            :samplerate => tags.samplerate,
            :vbr => tags.vbr,
            :content_type => tags.content_type,
            :size => file.size,
            :file => file)
          unless track.valid?
            logger.error(track.errors.full_messages.to_sentence)
            raise track.errors.full_messages.to_sentence
          end
        end
      end
    end
    return true
  end

  def download(&block)
    require 'tempfile'
    require 'aws/s3/prepare_path_fix'
    Tempfile.open('upload', File.join(Rails.root, 'tmp')) do |file|
      if bucket.present?
        AWS::S3::Base.establish_connection!(
          :access_key_id => ENV['AMAZON_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY'])
        s3obj = AWS::S3::S3Object.find(key, bucket)
        s3obj.value do |chunk|
          file.write(chunk)
        end
      else
        require 'net/http'
        uri = URI(key)
        Net::HTTP.get_response(uri) do |res|
          res.read_body do |chunk|
            file.write(chunk)
          end
        end
      end
      yield(file.flush)
    end
  rescue Net::HTTPNotFound => e
    return
  end

  def before_destroy
    AWS::S3::S3Object.delete(key, bucket) if bucket.present?
  end

  class <<self
    def generate_fingerprint(data)
      Digest::SHA1.hexdigest(data)
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
  end

end
