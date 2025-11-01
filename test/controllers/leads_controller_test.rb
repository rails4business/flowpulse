require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lead = leads(:one)
  end

  test "should get index" do
    get leads_url
    assert_response :success
  end

  test "should get new" do
    get new_lead_url
    assert_response :success
  end

  test "should create lead" do
    assert_difference("Lead.count") do
      post leads_url, params: { lead: { email: @lead.email, meta: @lead.meta, name: @lead.name, parent_id: @lead.parent_id, phone: @lead.phone, referral_lead_id: @lead.referral_lead_id, surname: @lead.surname, token: @lead.token, user_id: @lead.user_id, username_id: @lead.username_id } }
    end

    assert_redirected_to lead_url(Lead.last)
  end

  test "should show lead" do
    get lead_url(@lead)
    assert_response :success
  end

  test "should get edit" do
    get edit_lead_url(@lead)
    assert_response :success
  end

  test "should update lead" do
    patch lead_url(@lead), params: { lead: { email: @lead.email, meta: @lead.meta, name: @lead.name, parent_id: @lead.parent_id, phone: @lead.phone, referral_lead_id: @lead.referral_lead_id, surname: @lead.surname, token: @lead.token, user_id: @lead.user_id, username_id: @lead.username_id } }
    assert_redirected_to lead_url(@lead)
  end

  test "should destroy lead" do
    assert_difference("Lead.count", -1) do
      delete lead_url(@lead)
    end

    assert_redirected_to leads_url
  end
end
