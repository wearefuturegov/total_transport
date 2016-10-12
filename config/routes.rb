Rails.application.routes.draw do
  resource :passenger do
    member do
      get :verify
      post :verify
    end
  end
  devise_for :suppliers
  resources :routes do
    collection do
      get :suggest_route
      post :suggest_route
    end
    resources :bookings do
      member do
        get :choose_journey
        patch :save_journey
        get :choose_return_journey
        patch :save_return_journey
        get :choose_pickup_location
        patch :save_pickup_location
        get :choose_dropoff_location
        patch :save_dropoff_location
        get :choose_payment_method
        patch :save_payment_method
        get :add_payment_method
        post :create_payment_method
        get :confirm
        patch :save_confirm
        get :confirmation

        get :suggest_journey
        post :suggest_journey
        get :suggest_edit_to_stop
        post :suggest_edit_to_stop
      end
    end
  end

  root 'routes#index'

  namespace :admin do
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
  end
  get '/admin' => 'admin/journeys#index', as: :supplier_root # creates user_root_path

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
