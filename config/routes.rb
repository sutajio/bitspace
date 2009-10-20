ActionController::Routing::Routes.draw do |map|

  map.resource :upload
  map.resource :import
  map.root :controller => 'spaces'

end
