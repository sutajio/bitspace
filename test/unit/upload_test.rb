require 'test_helper'
require 'audioinfo/audioinfo'

class UploadTest < ActiveSupport::TestCase
  
  test "should be able to read and parse a valid image from the ID3 v.2.3 and v.2.4 APIC tag" do
    # This definition is based on http://www.id3.org/id3v2.4.0-frames - Section 4.14.
    
    #      Text encoding      $xx
    #      MIME type          <text string> $00
    #      Picture type       $xx ($03 for front cover)
    #      Description        <text string according to encoding> $00 (00)
    #      Picture data       <binary data>
    
    assert_equal nil, AudioInfo.image_from_id3_apic_tag(nil)
    assert AudioInfo.image_from_id3_apic_tag("\000image\\png\000\003\000blob").is_a?(StringIO)
    assert_equal 'blob', AudioInfo.image_from_id3_apic_tag("\000image\\png\000\003\000blob").read
    assert_equal 'blob', AudioInfo.image_from_id3_apic_tag("\000\000\003\000blob").read
  end
  
  test "should be able to read and parse a valid image from the ID3 v2.2 PIC tag" do
    # This definition is based on http://www.id3.org/id3v2-00 - Section 4.15.
    
    #      Text encoding      $xx
    #      Image format       $xx xx xx
    #      Picture type       $xx
    #      Description        <textstring> $00 (00)
    #      Picture data       <binary data>
    
    assert_equal nil, AudioInfo.image_from_id3_pic_tag(nil)
    assert AudioInfo.image_from_id3_pic_tag("\000PNG\003\000blob").is_a?(StringIO)
    assert_equal 'blob', AudioInfo.image_from_id3_pic_tag("\000PNG\003\000blob").read
  end
  
end
