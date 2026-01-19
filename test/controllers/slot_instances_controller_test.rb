require "test_helper"

class SlotInstancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @slot_instance = slot_instances(:one)
  end

  test "should get index" do
    get slot_instances_url
    assert_response :success
  end

  test "should get new" do
    get new_slot_instance_url
    assert_response :success
  end

  test "should create slot_instance" do
    assert_difference("SlotInstance.count") do
      post slot_instances_url, params: { slot_instance: { date_end: @slot_instance.date_end, date_start: @slot_instance.date_start, notes: @slot_instance.notes, slot_template_id: @slot_instance.slot_template_id, status: @slot_instance.status } }
    end

    assert_redirected_to slot_instance_url(SlotInstance.last)
  end

  test "should show slot_instance" do
    get slot_instance_url(@slot_instance)
    assert_response :success
  end

  test "should get edit" do
    get edit_slot_instance_url(@slot_instance)
    assert_response :success
  end

  test "should update slot_instance" do
    patch slot_instance_url(@slot_instance), params: { slot_instance: { date_end: @slot_instance.date_end, date_start: @slot_instance.date_start, notes: @slot_instance.notes, slot_template_id: @slot_instance.slot_template_id, status: @slot_instance.status } }
    assert_redirected_to slot_instance_url(@slot_instance)
  end

  test "should destroy slot_instance" do
    assert_difference("SlotInstance.count", -1) do
      delete slot_instance_url(@slot_instance)
    end

    assert_redirected_to slot_instances_url
  end
end
