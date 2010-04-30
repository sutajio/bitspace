ActionController::Routing::Routes.draw do |map|

  # Player
  map.resource :player
  map.resource :dashboard
  map.resource :search, :collection => { :suggestions => :get }
  map.resources :uploads, :collection => { :import => :post }
  map.resources :artists, :member => { :biography => :get, :artwork => :any }
  map.resources :releases, :member => { :archive => :put, :artwork => :any, :download => :get, :sideload => :post }
  map.resources :labels
  map.resources :years
  map.resources :tracks, :member => { :love => :put, :scrobble => :post, :now_playing => :post }
  map.resources :playlists, :collection => { :daycharts => :get, :weekcharts => :get, :recent => :get, :latest => :get, :toplist => :get }
  
  # Last.fm
  map.resources :lastfm, :collection => { :authorize => :get, :callback => :get }
  
  # Users and invitations
  map.resource :signup
  map.resources :users, :collection => { :unique => :get }
  map.resources :invitations
  map.resources :invitation_requests
  map.resources :user_sessions
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy', :requirements => { :method => 'delete' }
  map.resource :password, :member => { :forgot => :get, :reset => :get, :woohoo => :get }
  map.resource :account, :member => { :credentials => :any, :upgrade => :any, :profile => :any, :lastfm => :any, :api => :any, :invitations => :any, :valid_password => :get, :lastfm_scrobbling => :put, :reset_api_token => :put, :status => :get }
  
  # Pages
  map.price 'price', :controller => 'pages', :action => 'price'
  map.tour 'tour', :controller => 'pages', :action => 'tour'
  map.about 'about', :controller => 'pages', :action => 'about'
  map.download 'download', :controller => 'pages', :action => 'download'
  map.terms 'terms', :controller => 'pages', :action => 'terms'
  map.press 'press', :controller => 'pages', :action => 'press'
  map.atp 'atp', :controller => 'pages', :action => 'atp'
  
  # Blog
  map.blog 'blog', :controller => 'blog_posts', :action => 'index'
  map.blog_archive 'blog/archive/:year/:month/:slug', :controller => 'blog_posts', :action => 'show'
  map.blog_feed 'blog.atom', :controller => 'blog_posts', :action => 'index', :format => 'atom'
  
  # PayPal
  map.resources :payments, :collection => { :paypal_ipn => :post, :paypal_ipn_label => :post, :success => :get, :upgraded => :get, :cancel => :get }
  
  # Admin
  map.admin 'admin', :controller => 'admin', :action => 'index'
  map.admin_users 'admin/users', :controller => 'admin', :action => 'users'
  map.admin_status 'admin/status', :controller => 'admin', :action => 'status'
  map.admin_jobs 'admin/jobs', :controller => 'admin', :action => 'jobs'
  map.admin_run_job 'admin/run_job', :controller => 'admin', :action => 'run_job', :requirements => { :method => :post }
  map.admin_delete_job 'admin/delete_job', :controller => 'admin', :action => 'delete_job', :requirements => { :method => :delete }
  map.admin_blog 'blog/admin', :controller => 'blog_posts', :action => 'admin'
  map.resources :blog_posts
  
  # Clients
  map.resources :clients, :member => { :changelog => :get, :release_notes => :get, :download => :get }
  map.resources :client_versions, :member => { :download => :get }
  
  # Developerland
  map.resource :developer, :member => { :branding => :get, :authentication => :get, :upload => :get, :library => :get }
  
  # Root
  map.root :controller => 'pages', :action => 'index'
  
  # Public profiles
  map.profile ':profile_id', :controller => 'profiles', :action => 'show'
  map.follow_profile ':profile_id/follow', :controller => 'profiles', :action => 'follow', :requirements => { :method => :put }
  map.subscribe_profile ':profile_id/subscribe', :controller => 'profiles', :action => 'subscribe'

end
