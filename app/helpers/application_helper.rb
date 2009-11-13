# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def more(collection)
    link_to('...', polymorphic_path(collection.first.class.new, :page => params[:page].present? ? params[:page].to_i + 1 : 2), :rel => 'more', :class => 'more', :target => '_self')
  end
  
end
