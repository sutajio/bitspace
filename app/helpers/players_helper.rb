module PlayersHelper
  
  def use_html5_audio?
    user_agent = request.headers['User-Agent'] || ''
    return true if user_agent.include?('AppleWebKit') &&
                   user_agent.include?('Mobile')
    return false
  end
  
end
