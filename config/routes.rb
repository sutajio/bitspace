ActionController::Routing::Routes.draw do |map|

  # Player
  map.resource :player
  map.resource :dashboard
  map.resource :search, :collection => { :suggestions => :get }
  map.resources :uploads, :collection => { :import => :post }
  map.resources :artists, :member => { :biography => :get, :artwork => :any, :playlist => :get }
  map.resources :releases, :member => { :archive => :put, :artwork => :any, :download => :get, :sideload => :post, :playlist => :get }
  map.resources :tracks, :member => { :love => :put, :scrobble => :post, :now_playing => :post }
  map.resources :comments
  map.resources :devices
  
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
  map.resource :account, :member => { :credentials => :any, :upgrade => :any, :profile => :any, :lastfm => :any, :invitations => :any, :valid_password => :get, :lastfm_scrobbling => :put, :status => :get }
  
  # Pages
  map.download 'download', :controller => 'pages', :action => 'download'
  map.appstore 'appstore', :controller => 'pages', :action => 'appstore'
  map.terms 'terms', :controller => 'pages', :action => 'terms'
  
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
  
  # Root
  map.root :controller => 'players', :action => 'show'
  
  # Public profiles
  map.profile ':profile_id', :controller => 'profiles', :action => 'show'
  map.releases_profile ':profile_id/releases', :controller => 'releases', :action => 'index'
  map.follow_profile ':profile_id/follow', :controller => 'profiles', :action => 'follow', :requirements => { :method => :put }
  map.subscribe_profile ':profile_id/subscribe', :controller => 'profiles', :action => 'subscribe'
  map.thankyou_profile ':profile_id/thankyou', :controller => 'profiles', :action => 'thankyou'
  map.signup_profile ':profile_id/signup', :controller => 'profiles', :action => 'signup'
  map.devices_profile ':profile_id/devices', :controller => 'devices', :action => 'create', :requirements => { :method => :post }
  map.release_profile ':profile_id/:id', :controller => 'profiles', :action => 'release'

end
