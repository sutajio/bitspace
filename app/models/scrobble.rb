class Scrobble < ActiveRecord::Base

  belongs_to :user
  belongs_to :track, :counter_cache => true

  validates_presence_of :user_id
  validates_presence_of :track_id
  validates_presence_of :started_playing

  def perform
    submit_to_lastfm
  end
  
  def submit_to_lastfm
    self.class.lastfm_session(user) do |session|
      scrobble = Scrobbler::Scrobble.new(
                          :session_id => session.session_id,
                          :submission_url => session.submission_url,
                          :artist => track.artist ? track.artist.name :
                                                    track.release.artist.name,
                          :track => track.title,
                          :album => track.release.title,
                          :time => started_playing,
                          :length => track.length,
                          :track_number => track.track_nr,
                          :mb_track_id => track.mbid)
      scrobble.submit!
      logger.info("Scrobbler Submission Status: #{scrobble.status}")
    end
  end
  
  class <<self
    def now_playing(track, user)
      lastfm_session(user) do |session|
        playing = Scrobbler::Playing.new(
                            :session_id => session.session_id,
                            :now_playing_url => session.now_playing_url,
                            :artist => track.artist ? track.artist.name :
                                                      track.release.artist.name,
                            :track => track.title,
                            :album => track.release.title,
                            :length => track.length,
                            :track_number => track.track_nr,
                            :mb_track_id => track.mbid)
        playing.submit!
        logger.info("Playing Submission Status: #{playing.status}")
      end
    rescue BadSessionError => e
      logger.warn('BADSESSION error when submitting now playing track to Last.fm.')
    end
    
    handle_asynchronously :now_playing
  end
  
  protected

    def self.lastfm_session(user, &block)
      return unless user.connected_to_lastfm? && user.scrobble_to_lastfm?
      auth = Scrobbler::WebserviceAuth.new(:user => user.lastfm_username,
                                           :session_key => user.lastfm_session_key,
                                           :api_key => ENV['LASTFM_API_KEY'],
                                           :api_secret => ENV['LASTFM_SECRET_KEY'],
                                           :client_id => ENV['LASTFM_CLIENT_ID'] || 'tst',
                                           :client_ver => ENV['LASTFM_CLIENT_VERSION'] || '1.0')
      auth.handshake!
      logger.info("Auth Status: #{auth.status}")
      logger.info("Session ID: #{auth.session_id}")
      logger.info("Now Playing URL: #{auth.now_playing_url}")
      logger.info("Submission URL: #{auth.submission_url}")
      yield(auth)
    end

end
