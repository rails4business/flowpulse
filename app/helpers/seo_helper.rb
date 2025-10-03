# app/helpers/seo_helper.rb
module SeoHelper
  def seo_title(default: "Flowpulse")
    Current.brand&.seo&.fetch("title", nil).presence || Current.brand&.host || default
  end
  def seo_description
    Current.brand&.seo&.fetch("description", "").to_s
  end
  def seo_canonical_host
    Current.brand&.seo&.fetch("canonical_host", nil).presence || Current.brand&.host || request.host
  end
  def seo_theme_color
    Current.brand&.seo&.fetch("theme_color", nil).presence || "#000000"
  end
end
