require "application_system_test_case"

class TagPositioningsTest < ApplicationSystemTestCase
  setup do
    @tag_positioning = tag_positionings(:one)
  end

  test "visiting the index" do
    visit tag_positionings_url
    assert_selector "h1", text: "Tag positionings"
  end

  test "should create tag positioning" do
    visit tag_positionings_url
    click_on "New tag positioning"

    fill_in "Category", with: @tag_positioning.category
    fill_in "Metadata", with: @tag_positioning.metadata
    fill_in "Name", with: @tag_positioning.name
    fill_in "Post", with: @tag_positioning.post_id
    fill_in "Taxbranch", with: @tag_positioning.taxbranch_id
    click_on "Create Tag positioning"

    assert_text "Tag positioning was successfully created"
    click_on "Back"
  end

  test "should update Tag positioning" do
    visit tag_positioning_url(@tag_positioning)
    click_on "Edit this tag positioning", match: :first

    fill_in "Category", with: @tag_positioning.category
    fill_in "Metadata", with: @tag_positioning.metadata
    fill_in "Name", with: @tag_positioning.name
    fill_in "Post", with: @tag_positioning.post_id
    fill_in "Taxbranch", with: @tag_positioning.taxbranch_id
    click_on "Update Tag positioning"

    assert_text "Tag positioning was successfully updated"
    click_on "Back"
  end

  test "should destroy Tag positioning" do
    visit tag_positioning_url(@tag_positioning)
    accept_confirm { click_on "Destroy this tag positioning", match: :first }

    assert_text "Tag positioning was successfully destroyed"
  end
end
