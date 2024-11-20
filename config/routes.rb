Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  resources :ticker_events
  resources :tickers
  resources :players
  resources :teams
  resources :competitions
  resources :users
  resources :games
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  post "/api/login", to: "sessions#create"
  post "/api/logout", to: "sessions#destroy"
  post "/api/teams/:id/upload_logo", to: "teams#upload_team_logo"

  get "/api/users/:id/tickers", to: "tickers#get_ticker_by_user_id"
  get "/api/competitions/:id/teams", to: "competitions#teams"
  get "/api/competitions/:id/games", to: "competitions#games"
  get "/api/competitions/:id/games/:game_day", to: "competitions#games_by_day"
end
