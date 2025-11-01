module PagesHelper
  def flowpulse_color_map
    {
      "salute" => { base: "indigo", label: "blu" },
      "lavoro" => { base: "rose", label: "rosso" },
      "formazione" => { base: "emerald", label: "verde" }
    }
  end

  # Comodo per non esplodere se manca qualcosa
  def fp_color_for(cat)
    (flowpulse_color_map[cat] || { base: "gray" })[:base]
  end
end
