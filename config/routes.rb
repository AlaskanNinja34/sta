Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  resources :scholarship_applications, only: [:new, :create]
  
  # Set the form as your homepage
  root "scholarship_applications#new"
end
