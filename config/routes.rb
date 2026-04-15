Rails.application.routes.draw do
  rsc_payload_route

  resources :companies, only: %i[index show]
  resources :contacts, only: %i[index show]
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
