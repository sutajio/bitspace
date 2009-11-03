ActionController::Routing::Routes.draw do |map|

  map.resource :upload
  map.resource :search
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.resources :labels
  map.resources :years do |years|
    years.resources :releases
  end
  
  map.resources :user_sessions
  map.resources :users
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy', :requirements => { :method => 'delete' }
  
  map.resources :tracks, :member => { :love => :put, :unlove => :put }
  map.resources :playlists
  
  map.root :controller => 'spaces', :action => 'index'

end
