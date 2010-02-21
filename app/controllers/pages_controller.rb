class PagesController < ApplicationController
  layout 'site'
  skip_before_filter :require_user
  skip_before_filter :require_chrome_frame_if_ie
  
  def index
    @page_title = 'Music Backup, Music Organizer, HTML5 Music Player'
    @page_description = 'Keep your music in the cloud with Bitspace. Upload your collection and enjoy it every day, from anywhere. The best way to backup your music.'
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
  end
  
  def download
    @clients = Client.all
  end
  
end
