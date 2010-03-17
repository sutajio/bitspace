module PlayersHelper
  
  def use_html5_audio?
    user_agent = request.headers['User-Agent'] || ''
    true if user_agent.include?('AppleWebKit')
  end
  
end
