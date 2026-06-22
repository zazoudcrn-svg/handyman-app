Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root to: 'dashboards#show', as: :authenticated_root
  end
  root to: "pages#home"

  get "dashboard", to: "dashboards#show", as: :dashboard
  get "calendar", to: "dashboards#calendar", as: :calendar

  resources :offers, only: [:index]


  resources :listings, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      post :reopen
    end
    resources :offers, only: [:show, :new, :create, :edit, :update, :destroy] do
      collection do
        get :declined
      end
      member do
        patch :accept
        patch :decline
      end
      resources :messages, only: [:create]
    end
  end

  resources :bookings do
    member do
      patch :propose_date
      patch :accept_date
      patch :complete
      patch :cancel_booking
    end
  end

  resources :profiles, only: [:show, :edit, :update]
  resources :reviews, only: [:index, :new, :create]

  get "onboarding/customer", to: "onboardings#customer", as: :onboarding_customer
  patch "onboarding/customer_update", to: "onboardings#customer_update", as: :update_onboarding_customer
  get 'onboarding/contractor', to: 'onboardings#contractor', as: :onboarding_contractor
  patch 'onboarding/contractor', to: 'onboardings#contractor_update'
  patch '/skip_onboarding', to: 'onboardings#skip', as: :skip_onboarding
end
