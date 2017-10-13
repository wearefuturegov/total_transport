Rails.application.routes.draw do
  resources :log_entry, only: [:create]
  resources :passengers, except: :destroy do
    resources :sessions, only: [:new, :create]
    collection do
      delete :sign_out, to: 'sessions#destroy'
    end
    resources :bookings, only: :show
  end
  devise_for :suppliers, controllers: { registrations: "suppliers/registrations" }
  resources :suggested_routes, only: [:new, :create]
  resources :places, only: [:index, :show]
  resources :journeys, only: [:index] do
    collection do
      get ':from/(:to)' => 'journeys#index', as: :from_to
    end
  end
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
        resources :suggested_edit_to_stop, only: [:new, :create]
        
        get :confirmation
        get :price_api
      end
    end
  end

  root 'public#index'

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

      resources :stops
    end
    resources :suggestions
    resources :supplier_suggestions
    resources :promo_codes
    resources :bookings, only: :show
    resources :sms, only: [:new, :create]
    resources :places, only: [:new, :create]
    resources :placenames, only: [:index]
  end
  get '/admin' => 'admin/journeys#index', as: :supplier_root # creates user_root_path

end
