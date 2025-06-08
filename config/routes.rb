Rails.application.routes.draw do
  root 'sections#index'
  
  resources :sections, only: [:index, :show] do
    resources :questions, only: [:create]
    resources :responses, only: [:index]
    member do
      get :survey
      post :submit_survey
    end
  end
  
  resources :questions, only: [:index, :show]
  resources :answers, only: [:index, :show]
  resources :responses, only: [:index, :show]
  resources :metrics, only: [:index, :show]
  
  resources :sessions, only: [:new, :create, :destroy]
  get '/login', to: 'sessions#new'
  delete '/logout', to: 'sessions#destroy'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
