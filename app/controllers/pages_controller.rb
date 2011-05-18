class PagesController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def index
    response.headers['Cache-Control'] = 'public, max-age=300'
    @page_title = 'Crate Digger — Your music in the cloud'
    @page_description = 'Bitspace is a digital music service that lets you upload your own music to the cloud.'
    @page_keywords = 'music backup, music organizer, music library, html5 music player, audio tag, id3 tags, musicbrainz, last.fm, audioscrobbler, discogs'
  end

  def terms
    response.headers['Cache-Control'] = 'public, max-age=300'
    @page_title = 'Terms and Conditions'
  end

  def download
    response.headers['Cache-Control'] = 'public, max-age=300'
    @page_title = 'Download the Mac OS X Client'
    @clients = Client.all
  end

  def appstore
    redirect_to 'http://itunes.apple.com/us/app/bitspace/id386505557?mt=8&uo=4'
  end

end
