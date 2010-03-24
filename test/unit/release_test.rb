require 'test_helper'

class ReleaseTest < ActiveSupport::TestCase

  def setup
    @user = User.create!(:login => 'test', :email => 'test@example.com', :password => '123456', :password_confirmation => '123456')
    @artist = @user.artists.create!(:name => 'Test')
    @release = @artist.releases.create!(:title => 'Test', :user => @user)
    @track = @release.tracks.create!(:title => 'Test', :user => @user, :size => 0, :length => 0, :fingerprint => 'test')
  end

  test "should rename release" do
    @release.rename('New name')
    assert_equal 'New name', @release.reload.title
  end
  
  test "should merge with existing release if one exist when renaming" do
    @existing_release = @artist.releases.create!(:title => 'Existing release', :user => @user)
    assert_difference 'Release.count', -1 do
      assert_equal @existing_release, @release.rename('Existing release')
      assert_equal 'Existing release', @existing_release.reload.title
    end
  end
  
  test "should rename artist" do
    assert_difference 'Artist.count', 1 do
      @release.rename_artist('New name')
      assert_equal 'New name', @release.reload.artist.name
    end
  end
  
  test "should rename artist and use existing artist if one exist" do
    @existing_artist = @user.artists.create!(:name => 'Existing artist')
    assert_no_difference 'Artist.count' do
      @release.rename_artist('Existing artist')
      assert_equal 'Existing artist', @release.reload.artist.name
    end
  end
  
  test "should merge with existing release if one exist when renaming artist" do
    @existing_artist = @user.artists.create!(:name => 'Existing artist')
    @existing_release = @existing_artist.releases.create!(:title => 'Test', :user => @user)
    assert_difference 'Release.count', -1 do
      assert_equal @existing_release, @release.rename_artist('Existing artist')
      assert_equal 'Test', @existing_release.reload.title
    end
  end
  
  test "should rename tracks" do
    @release.rename_tracks({ @track.id => { :title => 'New title' }})
    assert_equal 'New title', @release.reload.tracks.first.title
  end
  
  test "should rename track artists" do
    @release.rename_tracks({ @track.id => { :artist => 'New artist' }})
    assert_equal 'New artist', @release.reload.tracks.first.artist.name
  end
  
  test "should change year" do
    @release.change_year(2010)
    assert_equal 2010, @release.reload.year
  end

end
