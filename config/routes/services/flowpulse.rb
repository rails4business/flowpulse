scope module: "flowpulse", path: "/" do
  scope path: "/onlinecourses", as: "flowpulse_onlinecourses" do
    # già presenti:
    get "/",                     to: "onlinecourses#index", as: :index
    get "/f/*folder_path",       to: "onlinecourses#index", as: :folder
    get "/i/*folder_path/:slug", to: "onlinecourses#show",  as: :item_in_folder
    get "/:slug",                to: "onlinecourses#show",  as: :item


    # 👇 LEZIONI: URL forte per singola lezione dentro un corso
    get "/courses/:content_slug/lessons/:lesson_slug",
        to: "lessons#show",
        as: :lesson
  end

  # --- BLOG Flowpulse ---
  scope path: "/blog", as: "flowpulse_blog" do
    get "/",      to: "posts#index", as: :index
    get "/:slug", to: "posts#show",  as: :post
  end
end



# Eccolo, sì 👇 (correggo anche il tuo esempio: è :3000, non org3000)

# Index corso (lista corsi)
# https://flowpulse.posturacorretta.org:3000/onlinecourses
# helper: flowpulse_onlinecourses_index_path

# Index su una cartella specifica
# https://flowpulse.posturacorretta.org:3000/onlinecourses/f/01_salute/01_posturacorretta/01_postura-e-fisiologia
# helper: flowpulse_onlinecourses_folder_path(folder_path: "...")

# Pagina del corso “Igiene Posturale” (slug “igiene-posturale”)
# https://flowpulse.posturacorretta.org:3000/onlinecourses/igiene-posturale
# helper: flowpulse_onlinecourses_item_path(slug: "igiene-posturale")
# (il controller cerca sotto @ctx.default_folder e discendenti)

# Pagina del corso con folder esplicito
# https://flowpulse.posturacorretta.org:3000/onlinecourses/i/01_salute/01_posturacorretta/01_postura-e-fisiologia/igiene-posturale
# helper: flowpulse_onlinecourses_item_in_folder_path(folder_path: "...", slug: "igiene-posturale")

# Ancora (permalinks) alle singole lezioni dentro la pagina corso
# #lesson-igiene_posturale_l1, #lesson-pratica_mobilizzazioni, ecc.
# (già generati dalla view; nessuna rotta extra necessaria)

# (Opzionale, se attivi la rotta lezioni dedicate)
# https://flowpulse.posturacorretta.org:3000/onlinecourses/courses/corso-igiene-posturale/lessons/igiene_posturale_l1
# helper: flowpulse_onlinecourses_lesson_path(content_slug: "corso-igiene-posturale", lesson_slug: "igiene_posturale_l1")

# Se preferisci usare le route generiche invece delle specializzate, equivalenti:
# service_item_path(key: "onlinecourses", folder_path: "...", slug: "igiene-posturale").
