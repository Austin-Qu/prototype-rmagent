Rails.application.routes.draw do

  get 'invite/index'
  match '/invite' => 'invite#index', via: [:get, :post]
  post 'invite/request_invite'
  get 'invite/request_sent'

  get 'statement/index'
  match '/statement' => 'statement#index', via: [:get, :post]
  get 'website_terms/index'
  match '/website_terms' => 'statement#index', via: [:get, :post]
  get 'customer_terms/index'
  match '/customer_terms' => 'statement#index', via: [:get, :post]
  get 'privacy/index'
  match '/privacy' => 'privacy#index', via: [:get, :post]

  get 'locations/suburb_state_postcode'

  get 'users/apply_now'
  post 'users/apply'
  get 'users/email_sent'
  get 'users/password_reset_sent'

  get 'home/index'

  get 'mates/index'

  get 'messages/index'
  get 'messages/activation_code'
  get 'messages/contact_form'
  get 'inspections_leads/ajax_update'
  post 'inspections_leads/delete_inspection_leads'
  post 'inspections_leads/set_rating'

  # devise_for :users
  devise_for :users, :controllers => { :registrations => "users/registrations", :passwords => "users/passwords" }
  # get 'today/index'

  resources :today
  # resources :user
  resource :user, only: [:edit] do
    collection do
      patch 'update_password'
    end
  end
  resources :inspections_lead
  resources :email_templates do
    collection do
      post :ipad_email_setting
    end
  end

  resources :user_profiles do
    collection do
      get :ajax_update
      post :upload
      get :get_user_profile
    end
  end

  resources :inspections do
    collection do
      get :ajax_update
      post :upload
      post :upload_attachment
      get :delete_property_file
      post :upload_property_file
      get :get_leads_emails_by_user
      post :send_bulk_email
      post :filter_inspection_leads
      post :inspection_sold
      post :create_default
      post :render_inspection
      post :render_panel_heading
      post :filter
    end
  end
  resources :leads do
    collection do
      get :ajax_update
      post :search
      post :delete_leads
      post :send_bulk_email
      post :upload_file
    end
  end

  namespace :api do
    namespace :v1 do
      resources :inspections do
        collection do
          get :get_inspections_by_user
        end
      end
      resources :leads do
        collection do
          get :get_leads_by_inspection
          get :get_all_leads_by_user
          post :upload_leads_for_inspection
        end
      end
      resources :users do
        collection do
          get :login
        end
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

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

  match "/404" => "errors#error404", via: [ :get, :post, :patch, :delete ]

end
