require 'test_helper'

class TracksHelperTest < ActionView::TestCase
  
  test "seconds to time should return time without leading zero, unless less than 60 seconds" do
    assert_equal '1:01', seconds_to_time(1.minute + 1.second)
    assert_equal '0:59', seconds_to_time(59.seconds)
    assert_equal '1:00:00', seconds_to_time(1.hour)
  end
  
end
