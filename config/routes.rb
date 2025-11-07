Rails.application.routes.draw do
  # --- Admin ---
  namespace :superadmin do
    resources :domains
    resources :taxbranches do
      member do
        get  :positioning
        patch :move_up
        patch :move_down
        patch :move_left
        patch :move_right
      end
      resources :tag_positionings, only: [ :index, :create, :destroy ]
    end
    resources :leads do
      member { post :approve }
    end
  end

  resources :posts do
    # (facoltativo) in admin potrai creare SocialItem dal post
    # resources :social_items, only: [:index, :new, :create]
  end

  # --- Sessioni & pagine ---
  constraints ->(req) { req.session[:user_id].present? } do
    root "dashboard#home", as: :authenticated_root
  end
  resource  :session
  resources :passwords, param: :token
  get "/signup", to: "pages#signup"
  get "dashboard/igieneposturale"
  get "dashboard/liste"
  get "dashboard/home"
    get "dashboard/evento"
  get "dashboard/superadmin"
  get "pages/home"
  get "pages/about"
  get "pages/contact"
  get "up" => "rails/health#show", as: :rails_health_check


  # Root pubblica
  #  root "pages#home", as: :unauthenticated_root
  root "posts#show", as: :unauthenticated_root
end
