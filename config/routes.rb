ActionController::Routing::Routes.draw do |map|

  # Player
  map.resource :player
  map.resource :dashboard
  map.resource :search
  map.resources :uploads, :collection => { :import => :post }
  map.resources :artists do |artists|
    artists.resources :releases, :member => { :archive => :put }
  end
  map.resources :releases
  map.resources :labels
  map.resources :years do |years|
    years.resources :releases
  end
  map.resources :tracks, :member => { :love => :put, :scrobble => :post, :now_playing => :post }
  map.resources :playlists
  
  # Last.fm
  map.resources :lastfm, :collection => { :authorize => :get, :callback => :get }
  
  # Users and invitations
  map.resources :users, :collection => { :unique => :get }
  map.resources :invitations
  map.resources :user_sessions
  map.resources :facebook_sessions
  map.facebook_logout 'fb-logout', :controller => 'facebook_sessions', :action => 'destroy', :requirements => { :method => 'delete' }
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy', :requirements => { :method => 'delete' }
  
  # Pages
  map.price 'price', :controller => 'pages', :action => 'price'
  map.tour 'tour', :controller => 'pages', :action => 'tour'
  map.about 'about', :controller => 'pages', :action => 'about'
  
  # Blog
  map.blog 'blog', :controller => 'blog_posts', :action => 'index'
  map.blog_archive 'blog/archive/:year/:month/:slug', :controller => 'blog_posts', :action => 'show'
  map.blog_feed 'blog.atom', :controller => 'blog_posts', :action => 'index', :format => 'atom'
  
  # PayPal
  map.resources :payments, :collection => { :paypal_ipn => :post, :success => :get, :cancel => :get }
  
  # Admin
  map.admin 'admin', :controller => 'admin', :action => 'index'
  map.admin_users 'admin/users', :controller => 'admin', :action => 'users'
  map.admin_status 'admin/status', :controller => 'admin', :action => 'status'
  map.admin_jobs 'admin/jobs', :controller => 'admin', :action => 'jobs'
  map.admin_run_job 'admin/run_job', :controller => 'admin', :action => 'run_job', :requirements => { :method => :post }
  map.admin_delete_job 'admin/delete_job', :controller => 'admin', :action => 'delete_job', :requirements => { :method => :delete }
  map.admin_blog 'blog/admin', :controller => 'blog_posts', :action => 'admin'
  map.resources :blog_posts
  
  # Root
  map.root :controller => 'pages', :action => 'index'

end
