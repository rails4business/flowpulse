# app/helpers/service_paths_helper.rb
module ServicePathsHelper
  def service_host_key(service_key:, brand_host:)
    sub = DomainRegistry.service(service_key)&.dig("subdomain") or return nil
    "#{sub}.#{brand_host}".tr(".", "_")
  end

  def service_item_url(brand_host:, service_key:, slug:, folders: nil, **opts)
    key = service_host_key(service_key:, brand_host:) or return nil
    name = folders.present? ? "svc_show_nested_#{key}_url" : "svc_show_#{key}_url"
    args = { key: service_key, slug: slug }
    args[:folders] = folders if folders.present?
    send(name, **args.merge(opts))
  end

  def service_index_url(brand_host:, service_key:, folders: nil, **opts)
    key = service_host_key(service_key:, brand_host:) or return nil
    name = folders.present? ? "svc_index_nested_#{key}_url" : "svc_index_#{key}_url"
    args = { key: service_key }
    args[:folders] = folders if folders.present?
    send(name, **args.merge(opts))
  end
end
