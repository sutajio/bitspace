require 'digest/md5'

module Scrobbler
  class WebserviceAuth
    # you should read last.fm/api/submissions#handshake
 
    attr_accessor :user, :session_key, :api_key, :api_secret, :client_id, :client_ver
    attr_reader :status, :session_id, :now_playing_url, :submission_url
 
    def initialize(args = {})
      @user = args[:user] # last.fm username
      @session_key = args[:session_key] # webservice session key
      @api_key = args[:api_key]
      @api_secret = args[:api_secret]
      @client_id = args[:client_id] || 'rbs' # Client ID assigned by last.fm; Don't change this!
      @client_ver = args[:client_ver] || Scrobbler::Version
 
      raise ArgumentError, 'Missing required argument' if @user.blank? ||
                                                          @session_key.blank? ||
                                                          @api_key.blank? ||
                                                          @api_secret.blank?
 
      @connection = REST::Connection.new(AUTH_URL)
    end
 
    def handshake!
      timestamp = Time.now.to_i.to_s
      token = Digest::MD5.hexdigest(@api_secret + timestamp)
 
      query = { :hs => 'true',
                :p => AUTH_VER,
                :c => @client_id,
                :v => @client_ver,
                :u => @user,
                :t => timestamp,
                :a => token,
                :api_key => @api_key,
                :sk => @session_key }
      result = @connection.get('/', query)
 
      @status = result.split(/\n/)[0]
      case @status
      when /OK/
        @session_id, @now_playing_url, @submission_url = result.split(/\n/)[1,3]
      when /BANNED/
        raise BannedError # something is wrong with the gem, check for an update
      when /BADAUTH/
        raise BadAuthError # invalid user/password
      when /FAILED/
        raise RequestFailedError, @status
      when /BADTIME/
        raise BadTimeError # system time is way off
      else
        raise RequestFailedError
      end  
    end
  end
end