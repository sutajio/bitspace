class PlaylistsController < ApplicationController
  
  skip_before_filter :require_user, :only => [:index, :toplist, :daycharts, :weekcharts, :recent, :latest]
  before_filter :find_user, :only => [:index, :toplist, :daycharts, :weekcharts, :recent, :latest]
  
  def index
    @tracks = @user.tracks.loved.paginate(:page => params[:page], :per_page => 100, :order => 'loved_at DESC')
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def toplist
    @tracks = @user.tracks.paginate(:page => params[:page], :per_page => 100, :order => 'scrobbles_count DESC', :conditions => ['scrobbles_count IS NOT NULL AND scrobbles_count != 0'])
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def daycharts
    @playlists = [
      ['Early morning  ☞ <span>(6:00 AM &ndash; 10:00 AM)</span>', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) IN (\'06\',\'07\',\'08\',\'09\')', '%H'])],
      ['Daytime  ☞ <span>(10:00 AM &ndash; 5:00 PM)</span>', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) IN (\'10\',\'11\',\'12\',\'13\',\'14\',\'15\',\'16\')', '%H'])],
      ['Early fringe  ☞ <span>(5:00 PM &ndash; 8:00 PM)</span>', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) IN (\'17\',\'18\',\'19\')', '%H'])],
      ['Prime time  ☞ <span>(8:00 PM &ndash; 11:00 PM)</span>', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) IN (\'20\',\'21\',\'22\')', '%H'])],
      ['Late fringe  ☞ <span>(11:00 PM &ndash; 3:00 AM)</span>', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) IN (\'23\',\'00\',\'01\',\'02\')', '%H'])],
      ['Graveyard  ☞ <span>(3:00 AM &ndash; 6:00 AM)</span>', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) IN (\'03\',\'04\',\'05\')', '%H'])]
    ]
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def weekcharts
    @playlists = [
      ['Monday', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) = \'1\'', '%w'])],
      ['Tuesday', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) = \'2\'', '%w'])],
      ['Wednesday', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) = \'3\'', '%w'])],
      ['Thursday', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) = \'4\'', '%w'])],
      ['Friday', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) = \'5\'', '%w'])],
      ['Saturday', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) = \'6\'', '%w'])],
      ['Sunday', @user.played_tracks.paginate(:page => 1, :per_page => 20, :order => 'scrobbles_count DESC', :conditions => ['STRFTIME(?, started_playing) = \'0\'', '%w'])]
    ]
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def recent
    @tracks = @user.played_tracks.paginate(:page => params[:page], :per_page => 100, :order => 'scrobbles.started_playing DESC')
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def latest
    @tracks = @user.tracks.paginate(:page => params[:page], :per_page => 100, :order => 'created_at DESC')
    respond_to do |format|
      format.html
      format.json
    end
  end
  
end
