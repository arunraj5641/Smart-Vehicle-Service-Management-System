Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Authentication Routes
      post "auth/login", to: "auth#login"
      post "auth/register", to: "auth#register"

      resources :users, only: [:create, :show]

      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"

      resources :vehicles, only: [:create, :index, :show, :update]

      resources :service_types, only: [:index, :create, :show, :update]

      resources :service_records, only: [:create, :index, :show, :update] do
        member do
          patch :status, to: "service_records#status_update"
        end
      end

      patch "service_records/:id", to: "service_records#update"
      patch "service_records/:id/status", to: "service_records#status"

      namespace :analytics do
        get :vehicle_costs
        get :monthly_costs
      end
    end
  end
end
