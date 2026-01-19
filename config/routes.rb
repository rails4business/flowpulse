Rails.application.routes.draw do
  resources :certificates
  resources :mycontacts do
    collection do
      post :lookup
    end
  end
  get "/datacontacts/:datacontact_id/mycontacts/new",
      to: "mycontacts#new_for_datacontact",
      as: :new_datacontact_mycontact
  resources :payments
  resources :bookings
  resources :enrollments
  resources :datacontacts
  resources :commitments
  resources :leads, only: [] do
    member do
      get :weekplan
    end
  end
  get "/book_index.json", to: "book_index#show"
  resources :journeys  do
    member do
      get "instance_cycle"
      post "clone_cycle"
      post "start_tracking"
      post "stop_tracking"
      get "carousel"
      get "rails4b"
      get "generaimpresa"
      post "replicate_template_events"
      delete "clear_template_events"
    end
    resources :commitments
    resources :eventdates
  end

  resources :taxbranches, only: [] do
    resources :eventdates, only: :index
  end

  get "taxbranches/:id/phase/index", to: "phase#index", as: :taxbranch_phase_index
  get "taxbranches/:id/phase/problema", to: "phase#problema", as: :taxbranch_phase_problema
  get "taxbranches/:id/phase/obiettivo", to: "phase#obiettivo", as: :taxbranch_phase_obiettivo
  get "taxbranches/:id/phase/previsione", to: "phase#previsione", as: :taxbranch_phase_previsione
  get "taxbranches/:id/phase/responsabile_progettazione", to: "phase#responsabile_progettazione", as: :taxbranch_phase_responsabile_progettazione
  get "taxbranches/:id/phase/step_necessari", to: "phase#step_necessari", as: :taxbranch_phase_step_necessari
  get "taxbranches/:id/phase/impegno", to: "phase#impegno", as: :taxbranch_phase_impegno
  get "taxbranches/:id/phase/realizzazione", to: "phase#realizzazione", as: :taxbranch_phase_realizzazione
  get "taxbranches/:id/phase/test", to: "phase#test", as: :taxbranch_phase_test
  get "taxbranches/:id/phase/attivo", to: "phase#attivo", as: :taxbranch_phase_attivo
  get "taxbranches/:id/phase/chiuso", to: "phase#chiuso", as: :taxbranch_phase_chiuso



  resources :eventdates  do
    resources :commitments
  end

  resources :myservices, only: :index

  # --- Admin ---
  namespace :superadmin do
    resources :services do
      member do
        get :rails4b
        get :generaimpresa
        get :servicemaps
      end
    end
    resources :domains do
      member do
        get :rails4b
        get :generaimpresa
        get :journey_map
        get :impegno
        post :create_station
        post :create_railservice
      end
    end
    resources :taxbranches do
      resources :services

      member do
        get  :journeys
        get  :positioning
        patch :move_up
        patch :move_down
        patch :move_left
        patch :move_right
        post :set_link_child
      end
      resources :tag_positionings, only: [ :index, :create, :destroy ]
    end
     resources :leads do
      member do
        post :approve
        post :reject

        get :rails4b
        get :generaimpresa
        get :impegno
      end
    end
  end

  # Area utente autenticato: i miei invitati
  namespace :account do
    resources :leads, only: [ :index, :create, :destroy ]
    resource  :profile, only: :show
  end


resources :posts do
    # Aggiunge una rotta POST per un membro specifico (un singolo post)
    # L'URL sarà /posts/:id/mark_done (ad esempio, /posts/6/mark_done)
    post :mark_done, on: :member # <--- QUESTA È LA ROTTA CORRETTA
    get :pricing, on: :member
  end


 # --- Sessioni & pagine ---
 # constraints ->(req) { req.session[:user_id].present? } do
 #   root "dashboard#home", as: :authenticated_root
 # end
 resource :session,       only: [ :new, :create, :destroy ]
  resource :registration,  only: [ :new, :create, :edit, :update ]
  resource :password_reset, only: [ :new, :create, :edit, :update ] # (nome può variare)
  get "/login",  to: "sessions#new",      as: :login
   get "/signup", to: "registrations#new", as: :signup
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
  get "/manifest.json", to: "pwa#manifest", as: :pwa_manifest
  get "/service-worker.js", to: "pwa#service_worker", as: :pwa_service_worker
  get "up" => "rails/health#show", as: :rails_health_check


  # Root pubblica
  #  root "pages#home", as: :unauthenticated_root
  root "posts#show"
end
