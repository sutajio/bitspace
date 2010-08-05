class PagesController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def index
    response.headers['Cache-Control'] = 'public, max-age=300'
    @page_title = 'Bitspace — Your music in the cloud'
    @page_description = 'Bitspace is a digital music service that lets you upload your own music to the cloud.'
    @page_keywords = 'music backup, music organizer, music library, html5 music player, audio tag, id3 tags, musicbrainz, last.fm, audioscrobbler, discogs'
  end
  
  def price
    redirect_to '/#price', :status => :moved_permanently
  end
  
  def tour
    response.headers['Cache-Control'] = 'public, max-age=300'
    @page_title = 'Take a Look Inside, Product Tour'
  end
  
  def about
    redirect_to '/#about', :status => :moved_permanently
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
  
  def press
    response.headers['Cache-Control'] = 'public, max-age=300'
    @page_title = 'Press kit for Bitspace'
  end
  
  def support
    redirect_to 'http://getsatisfaction.com/bitspace'
  end
  
  def atp
    response.headers['Cache-Control'] = 'public, max-age=300'
    @page_title = 'Bitspace at All Tomorrow\'s Parties Curated by Matt Groening'
  end
  
  def featured
    response.headers['Cache-Control'] = 'public, max-age=300'
    render :action => 'featured', :layout => false
  end
  
end
