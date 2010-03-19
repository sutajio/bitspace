class PagesController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def index
    @page_title = 'Bitspace — Your music in the cloud'
    @page_description = 'Bitspace is a digital music service that lets you upload your own music to the cloud.'
    @page_keywords = 'music backup, music organizer, music library, html5 music player, audio tag, id3 tags, musicbrainz, last.fm, audioscrobbler, discogs'
  end
  
  def price
    @page_title = 'Pricing and Signup - Bitspace'
  end
  
  def tour
    @page_title = 'Take a Look Inside, Product Tour - Bitspace'
  end
  
  def about
    @page_title = 'What is Bitspace?, FAQ, Help and Support - Bitspace'
  end
  
  def terms
    @page_title = 'Terms and Conditions - Bitspace'
  end
  
  def download
    @page_title = 'Download the Mac OS X Client - Bitspace'
    @clients = Client.all
  end
  
end
