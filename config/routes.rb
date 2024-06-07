Rails.application.routes.draw do
  get 'admins/refresh'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'pages#index'

  get '/servers', to: 'servers#index'
  get '/servers/:id', to: 'servers#show'
  get '/api/servers', to: 'servers#index_json'
  get '/api/servers/:id', to: 'servers#show_json'

  get '/404', to: 'errors#not_found'

  get '/panel/sync', to: 'admins#refresh'

  namespace :admins do
    resources :api_mgmnt, only: [] do
      collection do
        get :new
        post :create_api_token
      end
    end
  end

  resources :servers do
    member do
      get :websocket_console
      post :connect_websocket
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
