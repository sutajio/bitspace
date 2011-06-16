Bitspace::Application.routes.draw do

  resources :releases do
    collection do
      get :popular
      get :newest
    end
  end

  match '/now_playing' => 'tracks#now_playing'
  match '/scrobble' => 'tracks#scrobble'
  match '/love' => 'tracks#love'

  root :to => 'players#show'
  match '/popular' => 'players#show'
  match '/newest' => 'players#show'
  match '/:profile_id' => 'players#show'

end
