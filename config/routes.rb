Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations',
      confirmations: 'users/confirmations',
      passwords: 'users/passwords'
    },
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      sign_up: 'register'
    }

  root to: "home#index"
  resources :stats, only: [:index]
  resources :stores do
    post :approve_all, on: :collection
    resources :status_store_owners, only: [:new, :create]
  end
  resources :manage_stores, only: [:index]
  resources :user_stores, only: [:index, :update]
  resources :users
  resources :map

  require 'sidekiq/web'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
