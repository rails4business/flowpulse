require "test_helper"

class MycontactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mycontact = mycontacts(:one)
  end

  test "should get index" do
    get mycontacts_url
    assert_response :success
  end

  test "should get new" do
    get new_mycontact_url
    assert_response :success
  end

  test "should create mycontact" do
    assert_difference("Mycontact.count") do
      post mycontacts_url, params: { mycontact: { approved_by_referent_at: @mycontact.approved_by_referent_at, datacontact_id: @mycontact.datacontact_id, lead_id: @mycontact.lead_id, original: @mycontact.original, status_contact: @mycontact.status_contact } }
    end

    assert_redirected_to mycontact_url(Mycontact.last)
  end

  test "should show mycontact" do
    get mycontact_url(@mycontact)
    assert_response :success
  end

  test "should get edit" do
    get edit_mycontact_url(@mycontact)
    assert_response :success
  end

  test "should update mycontact" do
    patch mycontact_url(@mycontact), params: { mycontact: { approved_by_referent_at: @mycontact.approved_by_referent_at, datacontact_id: @mycontact.datacontact_id, lead_id: @mycontact.lead_id, original: @mycontact.original, status_contact: @mycontact.status_contact } }
    assert_redirected_to mycontact_url(@mycontact)
  end

  test "should destroy mycontact" do
    assert_difference("Mycontact.count", -1) do
      delete mycontact_url(@mycontact)
    end

    assert_redirected_to mycontacts_url
  end
end
