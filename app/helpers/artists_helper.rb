module ArtistsHelper
  
  def more(collection)
    link_to('...', artists_path(:page => params[:page].present? ? params[:page].to_i + 1 : 2), :rel => 'more', :class => 'more', :target => '_self')
  end
  
end
