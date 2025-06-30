Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'page#home'
  
  # Route pour le formulaire de contact
  post 'contacts', to: 'contacts#create'
  
  # Routes pour le système de commande (création seulement)
  get 'commandes/new', to: 'commandes#new', as: 'new_commande'
  post 'commandes', to: 'commandes#create'
  get 'commandes/:id', to: 'commandes#show', as: 'commande'
  
  # Routes panier
  post 'commandes/add_to_cart', to: 'commandes#add_to_cart', as: 'add_to_cart_commandes'
  delete 'commandes/remove_from_cart', to: 'commandes#remove_from_cart', as: 'remove_from_cart_commandes'
  patch 'commandes/update_cart', to: 'commandes#update_cart', as: 'update_cart_commandes'
  
  resources :plats, only: [:index, :show]
  resources :categories, only: [:index, :show]
  
  # Route de contact
  post 'contacts', to: 'contacts#create'
  
  
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
        delete :delete_completed
      end
    end
    
    # Gestion des plats
    resources :plats
    
    # Gestion des catégories
    resources :categories, except: [:show]
  end
end
