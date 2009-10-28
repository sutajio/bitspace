ActionController::Routing::Routes.draw do |map|

  map.resource :upload
  map.resource :search
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.resources :years do |years|
    years.resources :releases
  end
  map.root :controller => 'spaces'

end
