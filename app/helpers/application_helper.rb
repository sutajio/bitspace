# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def more(collection, options = {})
    return if collection.blank?
    case collection
    when Array:
      path = polymorphic_path(collection.first.class.new, :page => next_page, :profile_id => @user.login, :order => params[:order])
    when Hash:
      path = url_for(hash.merge(:page => next_page, :profile_id => @user.login, :order => params[:order]))
    when String:
      path = "#{collection}?page=#{next_page}&profile_id=#{@user.login}&order=#{params[:order]}"
    end
    link_to('...', path, :rel => 'more', :class => 'more', :target => '_self')
  end
  
  protected
  
    def next_page
      params[:page].present? ? params[:page].to_i + 1 : 2
    end
  
end
