Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: "pages#home"

  get "dashboard", to: "dashboards#show", as: :dashboard

  resources :offers, only: [ :index ] # ADDED
  resources :listings, only: [ :new, :create ] do
   resources :offers, only: [ :show, :new, :create ] do
    collection do
      get :declined
    end
    member do
      patch :accept
      patch :decline
    end
    resources :messages, only: [ :create ]
   end
  end

  resources :listings, only: [ :show, :edit, :update, :destroy ]

  resources :bookings do
    member do
     patch :propose_date
     patch :accept_date
     patch :complete
     patch :cancel_booking
   end
  end
  resources :profiles, only: [ :show, :edit, :update ]
  resources :reviews, only: [ :index, :new, :create ]

  get "onboarding/customer", to: "onboardings#customer", as: :onboarding_customer
  patch "onboarding/customer_update", to: "onboardings#customer_update", as: :update_onboarding_customer

  get 'onboarding/contractor', to: 'onboardings#contractor', as: :onboarding_contractor
  patch 'onboarding/contractor', to: 'onboardings#contractor_update'
  patch '/skip_onboarding', to: 'onboardings#skip', as: :skip_onboarding
end
