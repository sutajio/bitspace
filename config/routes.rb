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
  
  map.resources :invitations
  map.resources :user_sessions
  map.resources :users
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy', :requirements => { :method => 'delete' }
  
  map.price 'price', :controller => 'spaces', :action => 'price'
  map.tour 'tour', :controller => 'spaces', :action => 'tour'
  map.help 'help', :controller => 'spaces', :action => 'help'
  map.blog 'blog', :controller => 'spaces', :action => 'blog'
  
  map.resources :payments, :collection => { :paypal_ipn => :post, :success => :get, :cancel => :get }
  
  map.root :controller => 'spaces', :action => 'index'

end
