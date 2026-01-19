require "test_helper"

class SlotTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @slot_template = slot_templates(:one)
  end

  test "should get index" do
    get slot_templates_url
    assert_response :success
  end

  test "should get new" do
    get new_slot_template_url
    assert_response :success
  end

  test "should create slot_template" do
    assert_difference("SlotTemplate.count") do
      post slot_templates_url, params: { slot_template: { color_hex: @slot_template.color_hex, day_of_week: @slot_template.day_of_week, description: @slot_template.description, jsonb: @slot_template.jsonb, lead_id: @slot_template.lead_id, repeat_end: @slot_template.repeat_end, repeat_every: @slot_template.repeat_every, repeat_rule: @slot_template.repeat_rule, repeat_start: @slot_template.repeat_start, seasons: @slot_template.seasons, taxbranch_id: @slot_template.taxbranch_id, time_end: @slot_template.time_end, time_start: @slot_template.time_start, title: @slot_template.title } }
    end

    assert_redirected_to slot_template_url(SlotTemplate.last)
  end

  test "should show slot_template" do
    get slot_template_url(@slot_template)
    assert_response :success
  end

  test "should get edit" do
    get edit_slot_template_url(@slot_template)
    assert_response :success
  end

  test "should update slot_template" do
    patch slot_template_url(@slot_template), params: { slot_template: { color_hex: @slot_template.color_hex, day_of_week: @slot_template.day_of_week, description: @slot_template.description, jsonb: @slot_template.jsonb, lead_id: @slot_template.lead_id, repeat_end: @slot_template.repeat_end, repeat_every: @slot_template.repeat_every, repeat_rule: @slot_template.repeat_rule, repeat_start: @slot_template.repeat_start, seasons: @slot_template.seasons, taxbranch_id: @slot_template.taxbranch_id, time_end: @slot_template.time_end, time_start: @slot_template.time_start, title: @slot_template.title } }
    assert_redirected_to slot_template_url(@slot_template)
  end

  test "should destroy slot_template" do
    assert_difference("SlotTemplate.count", -1) do
      delete slot_template_url(@slot_template)
    end

    assert_redirected_to slot_templates_url
  end
end
