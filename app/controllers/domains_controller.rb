# app/controllers/domains_controller.rb
class DomainsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_scope
  helper_method :brands?

  def index
    @items = brands? ? Brand.order(:host) : ServiceDef.order(:key)
  end

  def show
    if brands?
      @item = Brand.find_by!(controller_slug: params[:id])
      hosts = [ @item.host, *Array(@item.aliases) ]
      @catalog_items = CatalogItem.where(
        "EXISTS (SELECT 1 FROM jsonb_array_elements_text(data->'domains') d(host) WHERE d.host = ANY (ARRAY[?]))",
        hosts
      )
    else
      @item = ServiceDef.find_by!(key: params[:id])
      @catalog_items = CatalogItem.where(service_key: @item.key)
    end
  end

  private
  def set_scope
    @scope = params[:scope].presence_in(%w[brands services]) || "brands"
  end
  def brands? = @scope == "brands"
end
