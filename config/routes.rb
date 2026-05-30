Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication Routes
      post "auth/login", to: "auth#login"
      post "auth/register", to: "auth#register"
      post "auth/logout", to: "auth#logout"
      get "me", to: "users#me"

      resources :users, only: [:index, :create, :show]

      resources :vehicles, only: [:create, :index, :show, :update, :destroy]

      resources :service_types, only: [:index, :create, :show, :update, :destroy]

      resources :service_records, only: [:create, :index, :show, :update] do
        member do
          patch :status, to: "service_records#status_update"
        end
      end
      namespace :analytics do
        get :vehicle_costs
        get :monthly_costs
      end
    end
  end
end
