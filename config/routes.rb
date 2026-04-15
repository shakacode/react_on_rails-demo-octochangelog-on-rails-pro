Rails.application.routes.draw do
  rsc_payload_route

  root "home#index"
  get "compare" => "compare#index"

  get "auth/github" => "github_auth#start", as: :github_auth_start
  get "auth/github/callback" => "github_auth#callback", as: :github_auth_callback
  delete "auth/github" => "github_auth#destroy", as: :github_auth

  namespace :api do
    get "github/repositories" => "github#repositories"
    get "github/releases" => "github#releases"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
