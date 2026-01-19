class LeadsController < ApplicationController
  before_action :set_lead

  def weekplan
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end
end
