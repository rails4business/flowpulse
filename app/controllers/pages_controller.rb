class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "landing"
  def home
  end

  def about
  end

  def contact
  end
end
