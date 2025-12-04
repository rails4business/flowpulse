require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = contacts(:one)
  end

  test "should get index" do
    get contacts_url
    assert_response :success
  end

  test "should get new" do
    get new_contact_url
    assert_response :success
  end

  test "should create contact" do
    assert_difference("Contact.count") do
      post contacts_url, params: { contact: { billing_address: @contact.billing_address, billing_city: @contact.billing_city, billing_country: @contact.billing_country, billing_name: @contact.billing_name, billing_zip: @contact.billing_zip, date_of_birth: @contact.date_of_birth, email: @contact.email, first_name: @contact.first_name, fiscal_code: @contact.fiscal_code, last_name: @contact.last_name, lead_id: @contact.lead_id, meta: @contact.meta, phone: @contact.phone, place_of_birth: @contact.place_of_birth, vat_number: @contact.vat_number } }
    end

    assert_redirected_to contact_url(Contact.last)
  end

  test "should show contact" do
    get contact_url(@contact)
    assert_response :success
  end

  test "should get edit" do
    get edit_contact_url(@contact)
    assert_response :success
  end

  test "should update contact" do
    patch contact_url(@contact), params: { contact: { billing_address: @contact.billing_address, billing_city: @contact.billing_city, billing_country: @contact.billing_country, billing_name: @contact.billing_name, billing_zip: @contact.billing_zip, date_of_birth: @contact.date_of_birth, email: @contact.email, first_name: @contact.first_name, fiscal_code: @contact.fiscal_code, last_name: @contact.last_name, lead_id: @contact.lead_id, meta: @contact.meta, phone: @contact.phone, place_of_birth: @contact.place_of_birth, vat_number: @contact.vat_number } }
    assert_redirected_to contact_url(@contact)
  end

  test "should destroy contact" do
    assert_difference("Contact.count", -1) do
      delete contact_url(@contact)
    end

    assert_redirected_to contacts_url
  end
end
