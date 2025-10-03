# prima (sbaglia perché prende anche i subdomini)
# constraints host: /(^|\.)posturacorretta\.org\z/i do

# dopo (solo host base, niente subdomini)
constraints host: /\Aposturacorretta\.org\z/i do
  root to: "brands/posturacorretta#home", as: :posturacorretta_root
  get "/about",   to: "brands/posturacorretta#about"
  get "/contact", to: "brands/posturacorretta#contact"
  get "/privacy", to: "brands/posturacorretta#privacy"
  get "/terms",   to: "brands/posturacorretta#terms"
  get "/p/:page", to: "brands/posturacorretta#page", as: :posturacorretta_page
end

constraints host: /\Aflowpulse\.net\z/i do
  root to: "brands/flowpulse#home", as: :flowpulse_root
  get "/about",   to: "brands/flowpulse#about"
  get "/contact", to: "brands/flowpulse#contact"
  get "/privacy", to: "brands/flowpulse#privacy"
  get "/terms",   to: "brands/flowpulse#terms"
  get "/p/:page", to: "brands/flowpulse#page", as: :flowpulse_page
end

# 1impegno.it idem:
constraints host: /\A1impegno\.it\z/i do
  root to: "brands/impegno1#home", as: :impegno1_root
  get "/about",   to: "brands/impegno1#about"
  get "/contact", to: "brands/impegno1#contact"
  get "/privacy", to: "brands/v#privacy"
  get "/terms",   to: "brands/impegno1#terms"
  get "/p/:page", to: "brands/impegno1#page", as: :impegno1_page
end
