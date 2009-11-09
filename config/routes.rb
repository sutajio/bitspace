ActionController::Routing::Routes.draw do |map|

  map.resource :search
  map.resources :uploads
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.resources :labels
  map.resources :years do |years|
    years.resources :releases
  end
  map.resources :tracks, :member => { :love => :put }
  map.resources :playlists
  
  map.resources :invitations
  map.resources :user_sessions
  map.resources :users
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy', :requirements => { :method => 'delete' }
  
  map.price 'price', :controller => 'pages', :action => 'price'
  map.tour 'tour', :controller => 'pages', :action => 'tour'
  map.help 'help', :controller => 'pages', :action => 'help'
  map.blog 'blog', :controller => 'blog_posts', :action => 'index'
  
  map.resources :payments, :collection => { :paypal_ipn => :post, :success => :get, :cancel => :get }
  
  map.admin_status 'admin/status', :controller => 'admin', :action => 'status'
  map.admin_jobs 'admin/jobs', :controller => 'admin', :action => 'jobs'
  map.admin_run_job 'admin/run_job', :controller => 'admin', :action => 'run_job', :requirements => { :method => :post }
  map.admin_delete_job 'admin/delete_job', :controller => 'admin', :action => 'delete_job', :requirements => { :method => :delete }
  map.admin_blog 'blog/admin', :controller => 'blog_posts', :action => 'admin'
  map.resources :blog_posts
  
  map.root :controller => 'pages', :action => 'index'

end
