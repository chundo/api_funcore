Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'
  namespace :api, defaults: { format: :json } do
    namespace :v1, defaults: { format: :json } do
      get 'shopify_products' => 'home#shopify_products'
      post 'shopify_create_product' => 'home#shopify_create_product'
      get 'shopify_product/:id' => 'home#shopify_product'
      put 'shopify_update_product/:id' => 'home#shopify_update_product'
      put 'shopify_disable_product/:id' => 'home#shopify_disable_product'
      delete 'shopify_delete_product/:id' => 'home#shopify_delete_product'
      get 'shopify_create_checkout/:id' => 'home#shopify_create_checkout'
      post 'shopify_orders' => 'home#shopify_orders'
      get 'shopify_orders' => 'home#shopify_orders'
      get 'shopify_order/:id' => 'home#shopify_order'
      resources :roles
      get 'parameters/find' => 'parameters#find'
      resources :parameters
      post 'users/login' => 'users#login'
      post 'users/magic_link' => 'users#magic_link'
      post 'users/sing_in_link' => 'users#sing_in_link'
      get 'users/find_users' => 'users#find_users'
      get 'users/find_user' => 'users#find_user'
      post 'users/phone_exist' => 'users#phone_exist'
      post 'users/user_verify' => 'users#user_verify'
      post 'users/resend_code' => 'users#resend_code'
      post 'users/sing_in' => 'users#login'
      post 'users/sing_up' => 'users#sing_up'
      get 'users/me' => 'users#me'
      delete 'users/disable/:id' => 'users#disable'
      post 'users/reset_password' => 'users#reset_password'
      post 'users/new_password' => 'users#new_password'
      post 'users/update_password' => 'users#update_password'
      post 'users/update_user' => 'users#update_user'
      root 'home#index'
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: 'api/v1/omniauth_callbacks' }

  devise_scope :user do
    get 'api/v1/users/auth/sign_out', to: 'devise/sessions#destroy'
    get 'api/v1/users/auth/sign_out2', to: 'api/v1/omniauth_callbacks#destroy'
    get 'api/v1/users/auth/:provider/callback' => 'api/v1/omniauth_callbacks#connector'
  end

  use_doorkeeper
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  authenticate :user, ->(user) { User.is_super?(user) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :magic_links
  resources :profiles
  resources :permissions
  resources :parameters
  get 'my_models/migrate' => 'my_models#migrate'
  resources :my_models
  resources :user_roles
  resources :roles
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
end
