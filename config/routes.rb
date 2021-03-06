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

  resources :map
  resources :pins, except: [:show]

  scope '/users' do
    devise_scope :user do
      get :close, to: 'users/registrations#destroy', as: 'close_user_registration'
    end
  end

  namespace :admin do
    resources :pins, controller: 'stores', except: [:new] do
      # post :approve_all, on: :collection
      post :approve, on: :member
    end
    resources :manage_stores, only: [:index]
    resources :user_stores, only: [:index, :update]
    resources :users do
      post :approve, on: :member
    end
  end

  require 'sidekiq/web'
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
