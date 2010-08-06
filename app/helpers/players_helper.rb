module PlayersHelper
  
  def use_html5_audio?
    user_agent = request.headers['User-Agent'] || ''
    return false if user_agent.match(/Mac OS X 10_6/)
    return true if user_agent.include?('AppleWebKit')
    return false
  end
  
end
