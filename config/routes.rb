Rails.application.routes.draw do
namespace :superadmin do
  resources :domains
  resources :taxbranches do
    member do
      patch :move_up
      patch :move_down
      patch :move_left   # outdent
      patch :move_right  # indent
      patch :addparent
    end
  end

  resources :leads  do
    member { post :approve }
  end
  resources :leads, only: [ :new, :create, :show, :index ] do
      member do
        post :approve # POST /leads/:id/approve
      end
  end
end
  # config/routes.rb
  # config/routes.rb

  constraints ->(req) { req.session[:user_id].present? } do
    root "dashboard#home", as: :authenticated_root
  end


  get "/signup", to: "pages#signup"

  resource :session
  resources :passwords, param: :token

    get "dashboard/igieneposturale"
  get "dashboard/liste"
  get "dashboard/home"
  get "dashboard/superadmin"
  get "pages/home"
  get "pages/about"
  get "pages/contact"




  root "pages#home", as: :unauthenticated_root
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

   # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
   # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
   # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

   # Defines the root path route ("/")
   # root "posts#index"
   get "posturacorretta", to: "pages#posturacorretta"
   get "igiene_posturale", to: "pages#igiene_posturale"
end
