Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Scholarship application routes
  resources :scholarship_applications, only: [ :new, :create, :show ] do
    member do
      get :confirmation
    end
  end

  # Application status lookup
  get "check_status", to: "scholarship_applications#check_status"
  post "lookup", to: "scholarship_applications#lookup"

  # Admin routes (will add devise later)
  namespace :admin do
    get "dashboard", to: "dashboard#index"
    get "application_table", to: "scholarship_applications#table_view"
    patch "bulk_update_status", to: "scholarship_applications#bulk_update_status"
    get "export_applications", to: "scholarship_applications#export_applications"

    resources :scholarship_applications do
      collection do
        get :export_csv
      end
      member do
        patch :approve
        patch :reject
        patch :request_more_info
      end
    end
  end

  # Defines the root path route ("/")
  root "home#index"
end
