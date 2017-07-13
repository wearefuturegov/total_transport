Rails.application.routes.draw do
  resources :passengers do
    resources :sessions, only: [:new, :create]
    resources :bookings, only: :show
  end
  devise_for :suppliers, controllers: { registrations: "suppliers/registrations" }
  resources :suggested_routes, only: [:new, :create]
  resources :routes do
    resources :bookings do
      member do
        BookingsWorkflow::STEPS.each do |route|
          get "edit_#{route}", action: :edit, as: "edit_#{route}", step: route
        end
        
        BookingsWorkflow::STEPS.each do |route|
          patch "save_#{route}", action: :update, as: "save_#{route}", step: route
        end
                
        resources :suggested_journey, only: [:new, :create]
        
        get :confirmation
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
