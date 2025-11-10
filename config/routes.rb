Rails.application.routes.draw do
  resources :eventdates
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
    # Aggiunge una rotta POST per un membro specifico (un singolo post)
    # L'URL sarà /posts/:id/mark_done (ad esempio, /posts/6/mark_done)
    post :mark_done, on: :member # <--- QUESTA È LA ROTTA CORRETTA
  end


  # --- Sessioni & pagine ---
  # constraints ->(req) { req.session[:user_id].present? } do
  #   root "dashboard#home", as: :authenticated_root
  # end
  resource :registration, only: [ :create, :edit, :update ]
resource :session, only: [ :new, :create, :destroy ]

  # unauthenticated do
  #   root to: "sessions#new", as: :unauthenticated_root
  # end

  # authenticated do
  #   root to: "dashboard#show", as: :authenticated_root
  # end


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
  root "posts#show"
end
