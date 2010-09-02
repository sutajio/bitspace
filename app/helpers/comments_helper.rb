module CommentsHelper
  
  def plain_text(text)
    auto_link(
      simple_format(
        escape_once(text)
      ), :all, :target => '_blank', :class => 'external') {|link|
        truncate(link, :length => 35)
      }
  end
  
end
