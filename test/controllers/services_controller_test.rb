require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @service = services(:one)
  end

  test "should get index" do
    get services_url
    assert_response :success
  end

  test "should get new" do
    get new_superadmin_service_url
    assert_response :success
  end

  test "should create service" do
    assert_difference("Service.count") do
      post services_url, params: { service: { description: @service.description, lead_id: @service.lead_id, max_tickets: @service.max_tickets, meta: @service.meta, min_tickets: @service.min_tickets, n_eventdates_planned: @service.n_eventdates_planned, name: @service.name, open_by_journey: @service.open_by_journey, price_ticket_dash: @service.price_ticket_dash, price_enrollment_euro: @service.price_enrollment_euro, taxbranch_id: @service.taxbranch_id } }
    end

    assert_redirected_to service_url(Service.last)
  end

  test "should show service" do
    get service_url(@service)
    assert_response :success
  end

  test "should get edit" do
    get edit_service_url(@service)
    assert_response :success
  end

  test "should update service" do
    patch service_url(@service), params: { service: { description: @service.description, lead_id: @service.lead_id, max_tickets: @service.max_tickets, meta: @service.meta, min_tickets: @service.min_tickets, n_eventdates_planned: @service.n_eventdates_planned, name: @service.name, open_by_journey: @service.open_by_journey, price_ticket_dash: @service.price_ticket_dash, price_enrollment_euro: @service.price_enrollment_euro, taxbranch_id: @service.taxbranch_id } }
    assert_redirected_to service_url(@service)
  end

  test "should destroy service" do
    assert_difference("Service.count", -1) do
      delete service_url(@service)
    end

    assert_redirected_to services_url
  end
end
