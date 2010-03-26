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
    @page_title = 'Pricing and Signup'
  end
  
  def tour
    @page_title = 'Take a Look Inside, Product Tour'
  end
  
  def about
    @page_title = 'What is Bitspace?, FAQ, Help and Support'
  end
  
  def terms
    @page_title = 'Terms and Conditions'
  end
  
  def download
    @page_title = 'Download the Mac OS X Client'
    @clients = Client.all
  end
  
  def press
    @page_title = 'Press kit for Bitspace'
  end
  
end
