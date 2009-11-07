require 'test_helper'

class ArtistTest < ActiveSupport::TestCase
  include ActionController::UrlWriter
  
  TRICKY_ARTISTS = {
    'Atlas Sound' => 'Atlas+Sound',
    'Akron/Family' => 'Akron%2FFamily',
    'Why?' => 'Why%3F',
    'Aoki Takamasa + Tujiko Noriko' => 'Aoki+Takamasa+%2B+Tujiko+Noriko'
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
      assert Artist.find(y)
      assert Artist.find(y, :conditions => { :user_id => 1 })
    end
  end

end
