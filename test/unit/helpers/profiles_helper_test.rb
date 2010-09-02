require 'test_helper'

class ProfilesHelperTest < ActionView::TestCase
  
  test "url without protocol should return url without protocol" do
    assert_equal 'bitspace.com', url_without_protocol('http://bitspace.com/')
    assert_equal 'bitspace.com', url_without_protocol('http://bitspace.com')
    assert_equal 'bitspace.com', url_without_protocol('https://bitspace.com/')
    assert_equal 'bitspace.com', url_without_protocol('https://bitspace.com')
    assert_equal 'www.bitspace.com', url_without_protocol('http://www.bitspace.com/')
    assert_equal 'bitspace.com/test', url_without_protocol('http://bitspace.com/test/')
    assert_equal 'bitspace.com/test', url_without_protocol('http://bitspace.com/test')
    assert_equal 'bitspace.com/test', url_without_protocol('bitspace.com/test/')
    assert_equal 'bitspace.com/test', url_without_protocol('bitspace.com/test')
    assert_equal 'bitspace.com', url_without_protocol('bitspace.com/')
    assert_equal 'bitspace.com', url_without_protocol('bitspace.com')
    assert_equal 'bitspace', url_without_protocol('bitspace/')
    assert_equal 'bitspace', url_without_protocol('bitspace')
    assert_equal '', url_without_protocol('/')
    assert_equal '', url_without_protocol('')
    assert_equal nil, url_without_protocol(nil)
  end
  
end
