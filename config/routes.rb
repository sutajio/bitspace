ActionController::Routing::Routes.draw do |map|

  map.resource :upload
  map.resource :search
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.resources :years do |years|
    years.resources :releases
  end
  
  map.resources :user_sessions
  map.resources :users
  map.root :controller => "user_sessions", :action => "new" # optional, this just sets the root route

end
