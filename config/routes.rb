ActionController::Routing::Routes.draw do |map|

  map.resource :upload
  map.resource :import
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.root :controller => 'spaces'

end
