class Podcast < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :url
  
  SUPPORTED_MEDIA_TYPES = {
    'audio/mpeg' => 'mp3',
    'x-audio/mp3' => 'mp3',
    'audio/ogg' => 'oga',
    'application/ogg' => 'ogg',
    'audio/x-ms-wma' => 'wma',
    'audio/mp4' => 'm4a',
    'audio/x-m4a' => 'm4a',
    'application/mp4' => 'mp4',
    'audio/x-flac' => 'flac'
  }
  
  def import
    require 'rfeedfinder'
    require 'feed-normalizer'
    require 'open-uri'
    feed_url = Rfeedfinder.feed(url)
    if feed_url.present?
      logger.info("Importing podcast from #{feed_url}")
      feed = FeedNormalizer::FeedNormalizer.parse(open(feed_url))
      feed.entries.reverse.each do |entry|
        if last_check_at.nil? || (entry.date_published > last_check_at)
          if entry.enclosures.present?
            entry.enclosures.each do |enclosure|
              if SUPPORTED_MEDIA_TYPES.keys.include?(enclosure.type)
                enqueue_upload(enclosure.url)
              end
            end
          else
            urls = (find_media_content_urls(entry.content) + 
                    find_media_content_urls(entry.description) +
                    find_media_content_urls(entry.title))
            urls.uniq.each do |media_url|
              enqueue_upload(media_url)
            end
          end
        end
      end
      touch(:last_check_at)
    end
  end
  
  after_create :import
  handle_asynchronously :import
  
  protected
  
    def enqueue_upload(url)
      logger.info("Found new media file: #{url}")
      upload = Upload.new(:user_id => user.id, :key => url)
      upload.save!
      Delayed::Job.enqueue(upload, 1)
    end
  
    def find_media_content_urls(text)
      urls = []
      URI.extract(text.to_s) do |url|
        uri = URI.parse(url) rescue nil
        if uri
          SUPPORTED_MEDIA_TYPES.values.uniq.each do |extension|
            urls << url if uri.path.to_s.ends_with?(extension)
          end
        end
      end
      urls.uniq
    end
  
end
