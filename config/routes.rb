Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'page#home'
  
  # Routes pour le système de commande
  resources :commandes do
    member do
      patch :update_status
    end
    
    collection do
      post :add_to_cart
      delete :remove_from_cart
      patch :update_cart
    end
  end
  
  resources :plats, only: [:index, :show]
  resources :categories, only: [:index, :show]
  
  # Route pour contacter le restaurant
  get 'contact', to: 'page#contact'
  
  # Routes administrateur
  namespace :admin do
    root 'dashboard#index'
    
    # Authentification admin
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    
    # Gestion des commandes
    resources :commandes, only: [:index, :show, :edit, :update] do
      member do
        patch :change_status
      end
    end
    
    # Gestion des plats
    resources :plats
    
    # Gestion des catégories
    resources :categories, except: [:show]
  end
end
