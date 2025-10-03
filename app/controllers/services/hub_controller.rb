# app/controllers/services/hub_controller.rb
module Services
  class HubController < ApplicationController
    def show
      @ctx           = ContextResolver.new(request: request)
      @brand         = @ctx.brand
      @service_defs  = @ctx.active_services_for_subdomain
      @start_folder  = @ctx.default_folder
    end
  end
end
