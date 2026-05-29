Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      resources :users, only: [:create, :show]

      resources :vehicles, only: [:create, :index, :show]

      resources :service_types, only: [:index, :create]

      resources :service_records, only: [:create, :index, :show]

      namespace :analytics do
        get :vehicle_costs
        get :monthly_costs
      end

    end
  end
end