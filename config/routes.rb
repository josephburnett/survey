Rails.application.routes.draw do
  root 'forms#index'
  
  resources :forms do
    resources :sections, only: [:create]
    member do
      get :survey
      post :submit_survey
      patch :soft_delete
      patch :add_section
    end
  end
  
  resources :sections do
    resources :questions, only: [:create]
    member do
      patch :soft_delete
      patch :add_question
    end
  end
  
  resources :questions do
    member do
      patch :soft_delete
    end
  end
  
  resources :answers do
    member do
      patch :soft_delete
    end
  end
  
  resources :responses do
    member do
      patch :soft_delete
    end
  end
  
  resources :metrics do
    member do
      patch :soft_delete
    end
  end
  
  resources :dashboards do
    member do
      patch :soft_delete
    end
  end
  
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
