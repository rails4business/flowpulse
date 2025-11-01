require "application_system_test_case"

class LeadsTest < ApplicationSystemTestCase
  setup do
    @lead = leads(:one)
  end

  test "visiting the index" do
    visit leads_url
    assert_selector "h1", text: "Leads"
  end

  test "should create lead" do
    visit leads_url
    click_on "New lead"

    fill_in "Email", with: @lead.email
    fill_in "Meta", with: @lead.meta
    fill_in "Name", with: @lead.name
    fill_in "Parent", with: @lead.parent_id
    fill_in "Phone", with: @lead.phone
    fill_in "Referral lead", with: @lead.referral_lead_id
    fill_in "Surname", with: @lead.surname
    fill_in "Token", with: @lead.token
    fill_in "User", with: @lead.user_id
    fill_in "Username", with: @lead.username_id
    click_on "Create Lead"

    assert_text "Lead was successfully created"
    click_on "Back"
  end

  test "should update Lead" do
    visit lead_url(@lead)
    click_on "Edit this lead", match: :first

    fill_in "Email", with: @lead.email
    fill_in "Meta", with: @lead.meta
    fill_in "Name", with: @lead.name
    fill_in "Parent", with: @lead.parent_id
    fill_in "Phone", with: @lead.phone
    fill_in "Referral lead", with: @lead.referral_lead_id
    fill_in "Surname", with: @lead.surname
    fill_in "Token", with: @lead.token
    fill_in "User", with: @lead.user_id
    fill_in "Username", with: @lead.username_id
    click_on "Update Lead"

    assert_text "Lead was successfully updated"
    click_on "Back"
  end

  test "should destroy Lead" do
    visit lead_url(@lead)
    accept_confirm { click_on "Destroy this lead", match: :first }

    assert_text "Lead was successfully destroyed"
  end
end
