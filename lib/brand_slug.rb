# lib/brand_slug.rb
module BrandSlug
  module_function

  # es: "posturacorretta.org" -> "posturacorretta"
  #     "www.ilgiardinodelcorpo.it" -> "ilgiardinodelcorpo"
  #     "rails4b.com" -> "rails4b"
  def from_host(host)
    h = host.to_s.downcase.sub(/\Awww\./, "")
    h.split(".").first # parte prima del primo punto
  end
end
