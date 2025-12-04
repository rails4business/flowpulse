# app/helpers/journeys_helper.rb
module JourneysHelper
  def journey_date_label(journey)
    return "-" unless journey.current_stage_date.present?
    l(journey.current_stage_date.to_date, format: :short)
  end
end
