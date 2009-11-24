# Lastfm
module Lastfm
  LASTFM_API_URL = 'http://ws.audioscrobbler.com/2.0/'
  LASTFM_AUTH_URL = 'http://www.last.fm/api/auth/'
  
  def ws_call(method, args = {})
    params = args.merge(
      :method => method,
      :api_key => ENV['LASTFM_API_KEY']
    )
    res = Net::HTTP.post_form(URI.parse(LASTFM_API_URL),
      params.merge(
        :api_sig => ws_signature(params, ENV['LASTFM_SECRET_KEY'])))
    ws_parse_response(res.body)
  end
  
  def auth_url
    LASTFM_AUTH_URL + "?api_key=#{ENV['LASTFM_API_KEY']}"
  end
  
  module_function :ws_call
  module_function :auth_url
  
  private
  
    def ws_signature(parameters, secret_key)
      Digest::MD5.hexdigest(
        parameters.stringify_keys.sort.join + secret_key.to_s
      )
    end
  
    def ws_parse_response(response)
      puts response
      lfm = XmlSimple.xml_in(response)['lfm']
      pp lfm
      if lfm['status'] == 'failed'
        raise lfm['error']['__content__']
      end
      lfm
    end
    
    module_function :ws_signature
    module_function :ws_parse_response
end