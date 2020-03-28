Rails.application.routes.draw do
  devise_for :users
  scope "(:locale)", locale: /en|pt|es/ do
    root to: "home#index"
    resources :stores do
      post :approve_all, on: :collection
    end
    resources :users
  end

  namespace :api do
    namespace :v1 do
      jsonapi_resources :stores do end
      jsonapi_resources :status_crowdsource_users, only: [:create] do end
      jsonapi_resources :status_crowdsources, only: [:index] do end
      jsonapi_resources :status_generals, only: [:index] do end
    end
  end
end
