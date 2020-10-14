Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  scope "(:locale)", locale: /en|pt|es|sk/ do
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
  end

  require 'sidekiq/web'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
