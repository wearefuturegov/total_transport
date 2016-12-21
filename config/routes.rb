Rails.application.routes.draw do
  resource :passenger do
    member do
      get :verify
      post :verify
    end
    resources :bookings, only: :show
  end
  devise_for :suppliers, controllers: { registrations: "suppliers/registrations" }
  resources :routes do
    collection do
      get :suggest_route
      post :suggest_route
    end
    resources :bookings do
      member do
        get :choose_requirements
        patch :save_requirements
        get :choose_journey
        patch :save_journey
        get :choose_return_journey
        patch :save_return_journey
        get :choose_pickup_location
        patch :save_pickup_location
        get :choose_dropoff_location
        patch :save_dropoff_location
        get :confirm
        patch :save_confirm
        get :confirmation

        get :suggest_journey
        post :suggest_journey
        get :suggest_edit_to_stop
        post :suggest_edit_to_stop

        get :price_api
      end
    end
  end

  root 'routes#index'

  namespace :admin do
    get 'pending' => 'suppliers#pending'
    root 'journeys#index'
    resource :team
    resources :vehicles
    resources :journeys do
      collection do
        get 'surrounding_journeys'
      end
      member do
        post 'send_message'
      end
    end
    resources :suppliers
    resources :routes do
      member do
        put 'sort'
      end

      resources :stops do
        resources :landmarks
      end
    end
    resources :suggestions
    resources :supplier_suggestions
    resources :promo_codes
    resources :bookings, only: :show
  end
  get '/admin' => 'admin/journeys#index', as: :supplier_root # creates user_root_path

end
