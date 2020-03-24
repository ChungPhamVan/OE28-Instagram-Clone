Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#index"
    
    get "/feeds", to: "static_pages#index"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    
    resources :users do
      resources :posts, only: :index
      member do
        get :following, to: "follows#following"
        get :followers, to: "follows#followers"
        get :bookmarking, to: "bookmarks#index"
      end
    end

    resources :posts do
      member do
        get :likers, to: "likes#index"
      end
      resources :comments, only: %i(create index destroy)   
    end

    resources :comments, only: %i(update destroy)
    resources :relationships, only: %i(update create destroy)
    resources :likes, :bookmarks, only: %i(create destroy)
    resources :searches, only: :index
    resources :notifications, only: %i(index update destroy)
  end
end
