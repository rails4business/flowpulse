require "test_helper"

class TagPositioningsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tag_positioning = tag_positionings(:one)
  end

  test "should get index" do
    get tag_positionings_url
    assert_response :success
  end

  test "should get new" do
    get new_tag_positioning_url
    assert_response :success
  end

  test "should create tag_positioning" do
    assert_difference("TagPositioning.count") do
      post tag_positionings_url, params: { tag_positioning: { category: @tag_positioning.category, metadata: @tag_positioning.metadata, name: @tag_positioning.name, post_id: @tag_positioning.post_id, taxbranch_id: @tag_positioning.taxbranch_id } }
    end

    assert_redirected_to tag_positioning_url(TagPositioning.last)
  end

  test "should show tag_positioning" do
    get tag_positioning_url(@tag_positioning)
    assert_response :success
  end

  test "should get edit" do
    get edit_tag_positioning_url(@tag_positioning)
    assert_response :success
  end

  test "should update tag_positioning" do
    patch tag_positioning_url(@tag_positioning), params: { tag_positioning: { category: @tag_positioning.category, metadata: @tag_positioning.metadata, name: @tag_positioning.name, post_id: @tag_positioning.post_id, taxbranch_id: @tag_positioning.taxbranch_id } }
    assert_redirected_to tag_positioning_url(@tag_positioning)
  end

  test "should destroy tag_positioning" do
    assert_difference("TagPositioning.count", -1) do
      delete tag_positioning_url(@tag_positioning)
    end

    assert_redirected_to tag_positionings_url
  end
end
