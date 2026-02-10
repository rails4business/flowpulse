module Superadmin
  class BackupsController < ApplicationController
    include RequireSuperadmin

    def index; end
  end
end
