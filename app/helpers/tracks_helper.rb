module TracksHelper
  
  def seconds_to_time(seconds)
    if seconds < 1.minute
      "0:#{seconds.to_i}"
    elsif seconds < 1.hour
      Time.at(seconds.to_i).gmtime.strftime('%M:%S').gsub(/^0([1-9]+)/,'\1')
    elsif seconds < 24.hours
      Time.at(seconds.to_i).gmtime.strftime('%R:%S').gsub(/^0([1-9]+)/,'\1')
    else
      pluralize(seconds / 60 / 60 / 24, 'day')
    end
  end
  
end
