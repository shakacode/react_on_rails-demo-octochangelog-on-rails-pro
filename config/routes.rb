Rails.application.routes.draw do
  rsc_payload_route

  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
