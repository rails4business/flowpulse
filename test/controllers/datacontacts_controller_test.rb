require "test_helper"

class DatacontactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = datacontacts(:one)
  end

  test "should get index" do
    get datacontacts_url
    assert_response :success
  end

  test "should get new" do
    get new_contact_url
    assert_response :success
  end

  test "should create datacontact" do
    assert_difference("Datacontact.count") do
      post datacontacts_url, params: { datacontact: { billing_address: @datacontact.billing_address, billing_city: @datacontact.billing_city, billing_country: @datacontact.billing_country, billing_name: @datacontact.billing_name, billing_zip: @datacontact.billing_zip, date_of_birth: @datacontact.date_of_birth, email: @datacontact.email, first_name: @datacontact.first_name, fiscal_code: @datacontact.fiscal_code, last_name: @datacontact.last_name, lead_id: @datacontact.lead_id, meta: @datacontact.meta, phone: @datacontact.phone, place_of_birth: @datacontact.place_of_birth, vat_number: @datacontact.vat_number } }
    end

    assert_redirected_to datacontact_url(Datacontact.last)
  end

  test "should show datacontact" do
    get datacontact_url(@datacontact)
    assert_response :success
  end

  test "should get edit" do
    get edit_contact_url(@contact)
    assert_response :success
  end

  test "should update datacontact" do
    patch datacontact_url(@datacontact), params: { datacontact: { billing_address: @datacontact.billing_address, billing_city: @datacontact.billing_city, billing_country: @datacontact.billing_country, billing_name: @datacontact.billing_name, billing_zip: @datacontact.billing_zip, date_of_birth: @datacontact.date_of_birth, email: @datacontact.email, first_name: @datacontact.first_name, fiscal_code: @datacontact.fiscal_code, last_name: @datacontact.last_name, lead_id: @datacontact.lead_id, meta: @datacontact.meta, phone: @datacontact.phone, place_of_birth: @datacontact.place_of_birth, vat_number: @datacontact.vat_number } }
    assert_redirected_to datacontact_url(@datacontact)
  end

  test "should destroy datacontact" do
    assert_difference("Datacontact.count", -1) do
      delete datacontact_url(@datacontact)
    end

    assert_redirected_to datacontacts_url
  end
end
