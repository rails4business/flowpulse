require "application_system_test_case"

class TaxbranchesTest < ApplicationSystemTestCase
  setup do
    @taxbranch = taxbranches(:one)
  end

  test "visiting the index" do
    visit taxbranches_url
    assert_selector "h1", text: "Taxbranches"
  end

  test "should create taxbranch" do
    visit taxbranches_url
    click_on "New taxbranch"

    fill_in "Ancestry", with: @taxbranch.ancestry
    fill_in "Lead", with: @taxbranch.lead_id
    fill_in "Meta", with: @taxbranch.meta
    fill_in "Description", with: @taxbranch.description
    fill_in "Position", with: @taxbranch.position
    fill_in "Slug", with: @taxbranch.slug
    fill_in "Slug category", with: @taxbranch.slug_category
    fill_in "Slug label", with: @taxbranch.slug_label
    click_on "Create Taxbranch"

    assert_text "Taxbranch was successfully created"
    click_on "Back"
  end

  test "should update Taxbranch" do
    visit taxbranch_url(@taxbranch)
    click_on "Edit this taxbranch", match: :first

    fill_in "Ancestry", with: @taxbranch.ancestry
    fill_in "Lead", with: @taxbranch.lead_id
    fill_in "Meta", with: @taxbranch.meta
    fill_in "Description", with: @taxbranch.description
    fill_in "Position", with: @taxbranch.position
    fill_in "Slug", with: @taxbranch.slug
    fill_in "Slug category", with: @taxbranch.slug_category
    fill_in "Slug label", with: @taxbranch.slug_label
    click_on "Update Taxbranch"

    assert_text "Taxbranch was successfully updated"
    click_on "Back"
  end

  test "should destroy Taxbranch" do
    visit taxbranch_url(@taxbranch)
    accept_confirm { click_on "Destroy this taxbranch", match: :first }

    assert_text "Taxbranch was successfully destroyed"
  end
end
