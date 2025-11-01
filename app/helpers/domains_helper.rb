# app/helpers/domain_helper.rb
module DomainsHelper
  def domain_title(default: "PosturaCorretta")
    Current.domain&.title.presence || default
  end

  def domain_description(default: "")
    Current.domain&.description.presence || default
  end

  def domain_favicon_url
    Current.domain&.favicon_url
  end

  def domain_logo_square
    Current.domain&.square_logo_url
  end

  def domain_logo_horizontal
    Current.domain&.horizontal_logo_url
  end
end
