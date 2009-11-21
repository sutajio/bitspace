ActionController::Routing::Routes.draw do |map|

  map.resource :dashboard
  map.resource :search
  map.resources :uploads, :collection => { :import => :post }
  map.resources :artists do |artists|
    artists.resources :releases
  end
  map.resources :releases
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
  map.about 'about', :controller => 'pages', :action => 'about'
  map.blog 'blog', :controller => 'blog_posts', :action => 'index'
  map.blog_archive 'blog/archive/:year/:month/:slug', :controller => 'blog_posts', :action => 'show'
  map.blog_feed 'blog.atom', :controller => 'blog_posts', :action => 'index', :format => 'atom'
  
  map.resources :payments, :collection => { :paypal_ipn => :post, :success => :get, :cancel => :get }
  
  map.admin 'admin', :controller => 'admin', :action => 'index'
  map.admin_users 'admin/users', :controller => 'admin', :action => 'users'
  map.admin_status 'admin/status', :controller => 'admin', :action => 'status'
  map.admin_jobs 'admin/jobs', :controller => 'admin', :action => 'jobs'
  map.admin_run_job 'admin/run_job', :controller => 'admin', :action => 'run_job', :requirements => { :method => :post }
  map.admin_delete_job 'admin/delete_job', :controller => 'admin', :action => 'delete_job', :requirements => { :method => :delete }
  map.admin_blog 'blog/admin', :controller => 'blog_posts', :action => 'admin'
  map.resources :blog_posts
  
  map.root :controller => 'pages', :action => 'index'

end
