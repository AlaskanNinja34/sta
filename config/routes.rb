Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Student-facing application routes
  resources :applications, only: [:new, :create, :show] do
    member do
      get :confirmation
    end
  end

  # Application status lookup
  get "check_status", to: "applications#check_status"
  post "lookup", to: "applications#lookup"

  # Admin routes (will add devise later)
  namespace :admin do
    get "dashboard", to: "dashboard#index"

    # Legacy route - redirect to verification workflow
    get "application_table", to: redirect("/admin/verifications/workflow")

    # Verification Workflow - Excel-like main staff processing interface
    get "verification_workflow", to: "verifications#workflow", as: :verification_workflow

    # Verification Overview - Status/progress summary page
    get "verification_overview", to: "verifications#index", as: :verification_overview

    # Bulk operations for applications
    patch "bulk_update_status", to: "applications#bulk_update_status"
    get "export_applications", to: "applications#export_applications"

    resources :applications do
      collection do
        get :export_csv
      end
      member do
        get "view_file/:blob_id", action: :view_file, as: :view_file
        patch :approve
        patch :reject
        patch :request_more_info
      end
    end

    # Verification workflow
    resources :verifications, only: [:index, :show, :update]

    # Student profiles
    resources :students, only: [:index, :show, :new, :create, :edit, :update] do
      member do
        post :recalculate_totals
      end
    end

    # Historical application imports
    resources :historical_applications
  end

  # Defines the root path route ("/")
  root "home#index"
end
