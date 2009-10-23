ActionController::Routing::Routes.draw do |map|

  map.resource :upload
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.resources :years do |years|
    years.resources :releases
  end
  map.root :controller => 'artists'

end
