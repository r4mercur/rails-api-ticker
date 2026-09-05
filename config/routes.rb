Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :ticker_events
      resources :tickers
      resources :players
      resources :teams
      resources :competitions
      resources :users
      resources :games

      post "login", to: "sessions#create"
      post "logout", to: "sessions#destroy"
      post "teams/:id/upload_logo", to: "teams#upload_team_logo"

      get "users/:id/tickers", to: "tickers#get_ticker_by_user_id"
      get "competitions/:id/teams", to: "competitions#teams"
      get "competitions/:id/games", to: "competitions#games"
      get "competitions/:id/games/:game_day", to: "competitions#games_by_day"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
