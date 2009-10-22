ActionController::Routing::Routes.draw do |map|

  map.resource :upload
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.root :controller => 'spaces'

end
