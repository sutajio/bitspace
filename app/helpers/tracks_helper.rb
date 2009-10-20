module TracksHelper
  
  def seconds_to_time(seconds)
    if seconds > 1.hour
      Time.at(seconds).gmtime.strftime('%R:%S').gsub(/^0([1-9]+)/,'\1')
    else
      Time.at(seconds).gmtime.strftime('%M:%S').gsub(/^0([1-9]+)/,'\1')
    end
  end
  
end
