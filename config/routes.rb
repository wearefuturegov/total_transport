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
      get ':from/:to/bookings/new' => 'bookings#new', as: :new_booking
    end
  end
  resources :bookings do
    collection do
      post :price
    end
    member do
      resources :suggested_journey, only: [:new, :create]
      resources :suggested_edit_to_stop, only: [:new, :create]
      
      get :confirmation
      get :return_journeys
    end
  end
  
  resources :stops do
    resources :landmarks, only: [:index]
  end
  
  resources :routes

  root 'public#index'

  namespace :admin do
    get 'pending' => 'suppliers#pending'
    root 'journeys#index'
    #resource :team, only: [:show]
    resources :teams
    get :account, to: 'teams#show'
    resources :vehicles
    resources :journeys do
      collection do
        get 'surrounding_journeys'
      end
      member do
        post 'send_message'
      end
      resources :bookings, only: [:show]
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
  get '/bookings/:token/cancel', as: :cancel_booking, to: 'bookings#cancel'
  get '/bookings/cancelled', as: :booking_cancelled
  
end
