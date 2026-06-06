# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  get "/account/admin", to: "account_admin#show", as: :account_admin
  resource :account_admin_payments, path: "/account/admin/payments", only: [:show, :create]

  resources :events do
    collection do
      get :calendar
    end

    member do
      patch :open_flight
      patch :close_flight
    end

    resource :payment, controller: "event_payments", only: :create
  end
  resources :event_payments, only: :index
  resources :airplanes do
    resources :user_qualifications, controller: "airplane_user_qualifications", only: :create
    resources :maintenance_inspections, except: :show
  end
  draw :jumpstart

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  authenticated :user do
    root to: "events#index", as: :user_root
    # Alternate route to use if logged in users should still see public root
    # get "/dashboard", to: "dashboard#show", as: :user_root
  end

  # Public marketing homepage
  root to: "public#index"
end
