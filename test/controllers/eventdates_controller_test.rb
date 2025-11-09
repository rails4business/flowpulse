require "test_helper"

class EventdatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @eventdate = eventdates(:one)
  end

  test "should get index" do
    get eventdates_url
    assert_response :success
  end

  test "should get new" do
    get new_eventdate_url
    assert_response :success
  end

  test "should create eventdate" do
    assert_difference("Eventdate.count") do
      post eventdates_url, params: { eventdate: { cycle: @eventdate.cycle, date_end: @eventdate.date_end, date_start: @eventdate.date_start, description: @eventdate.description, lead_id: @eventdate.lead_id, meta: @eventdate.meta, status: @eventdate.status, taxbranch_id: @eventdate.taxbranch_id } }
    end

    assert_redirected_to eventdate_url(Eventdate.last)
  end

  test "should show eventdate" do
    get eventdate_url(@eventdate)
    assert_response :success
  end

  test "should get edit" do
    get edit_eventdate_url(@eventdate)
    assert_response :success
  end

  test "should update eventdate" do
    patch eventdate_url(@eventdate), params: { eventdate: { cycle: @eventdate.cycle, date_end: @eventdate.date_end, date_start: @eventdate.date_start, description: @eventdate.description, lead_id: @eventdate.lead_id, meta: @eventdate.meta, status: @eventdate.status, taxbranch_id: @eventdate.taxbranch_id } }
    assert_redirected_to eventdate_url(@eventdate)
  end

  test "should destroy eventdate" do
    assert_difference("Eventdate.count", -1) do
      delete eventdate_url(@eventdate)
    end

    assert_redirected_to eventdates_url
  end
end
