require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  include ActionController::UrlWriter
  
  TRICKY_ARTISTS = {
    'Atlas Sound' => 'Atlas+Sound',
    'Akron/Family' => 'Akron%2FFamily',
    'Why?' => 'Why%3F',
    'Aoki Takamasa + Tujiko Noriko' => 'Aoki%2BTakamasa%2B%252B%2BTujiko%2BNoriko',
    'O.Lamm' => 'O%2ELamm',
    'Dj Rolando A.K.A. Aztec Mystic' => 'Dj+Rolando+A%2EK%2EA%2E+Aztec+Mystic'
  }

  test "should handle weird characters in the artist name when the artist is used in an URL" do
    TRICKY_ARTISTS.each do |x,y|
      assert_equal y, Artist.new(:name => x).to_param
      assert artist_path(Artist.new(:name => x))
    end
  end
  
  test "should be able to find artists with weird characters in their name" do
    TRICKY_ARTISTS.each do |x,y|
      Artist.create(:name => x, :user_id => 1)
      assert Artist.find(URI.unescape(y))
      assert Artist.find(URI.unescape(y), :conditions => { :user_id => 1 })
    end
  end

end
