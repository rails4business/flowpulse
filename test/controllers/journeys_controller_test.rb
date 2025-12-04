require "test_helper"

class JourneysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @journey = journeys(:one)
  end

  test "should get index" do
    get journeys_url
    assert_response :success
  end

  test "should get new" do
    get new_journey_url
    assert_response :success
  end

  test "should create journey" do
    assert_difference("Journey.count") do
      post journeys_url, params: { journey: { complete: @journey.complete, energy: @journey.energy, importance: @journey.importance, lead_id: @journey.lead_id, template_journey_id: @journey.template_journey_id, meta: @journey.meta, notes: @journey.notes, price_estimate_dash: @journey.price_estimate_dash, price_estimate_euro: @journey.price_estimate_euro, progress: @journey.progress, service_id: @journey.service_id, start_erogation: @journey.start_erogation, start_ideate: @journey.start_ideate, start_realized: @journey.start_realized, taxbranch_id: @journey.taxbranch_id, title: @journey.title, urgency: @journey.urgency } }
    end

    assert_redirected_to journey_url(Journey.last)
  end

  test "should show journey" do
    get journey_url(@journey)
    assert_response :success
  end

  test "should get edit" do
    get edit_journey_url(@journey)
    assert_response :success
  end

  test "should update journey" do
    patch journey_url(@journey), params: { journey: { complete: @journey.complete, energy: @journey.energy, importance: @journey.importance, lead_id: @journey.lead_id, template_journey_id: @journey.template_journey_id, meta: @journey.meta, notes: @journey.notes, price_estimate_dash: @journey.price_estimate_dash, price_estimate_euro: @journey.price_estimate_euro, progress: @journey.progress, service_id: @journey.service_id, start_erogation: @journey.start_erogation, start_ideate: @journey.start_ideate, start_realized: @journey.start_realized, taxbranch_id: @journey.taxbranch_id, title: @journey.title, urgency: @journey.urgency } }
    assert_redirected_to journey_url(@journey)
  end

  test "should destroy journey" do
    assert_difference("Journey.count", -1) do
      delete journey_url(@journey)
    end

    assert_redirected_to journeys_url
  end
end
