require "test_helper"

class CommitmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @commitment = commitments(:one)
  end

  test "should get index" do
    get commitments_url
    assert_response :success
  end

  test "should get new" do
    get new_commitment_url
    assert_response :success
  end

  test "should create commitment" do
    assert_difference("Commitment.count") do
      post commitment commitmentesource.area, compensation_dash: @commitment.compensation_dash, compensation_euro: @commitment.compensation_euro, duration_minutes: @commitment.duration_minutes, energy: @commitment.energy, eventdate_id: @commitment.eventdate_id, importance: @commitment.importance, journey_id: @commitment.journey_id, meta: @commitment.meta, notes: @commitment.notes, position: @commitment.position, role: @commitment.role, role_count: @commitment.role_count, role_name: @commitment.role_name, commitment_kind: @commitment.commitment_kind, taxbranch_id: @commitment.taxbranch_id, urgency: @commitment.urgency } }
    end

    assert_redirected_to commitment_url(Commitment.last)
  end

  test "should show commitment" do
    get commitment_url(@commitment)
    assert_response :success
  end

  test "should get edit" do
    get edit_commitment_url(@commitment)
    assert_response :success
  end

  test "should update commitment" do
    patch commitment_url(@commitment), params: { commitment: { area: @commitment.area, compensation_dash: @commitment.compensation_dash, compensation_euro: @commitment.compensation_euro, duration_minutes: @commitment.duration_minutes, energy: @commitment.energy, eventdate_id: @commitment.eventdate_id, importance: @commitment.importance, journey_id: @commitment.journey_id, meta: @commitment.meta, notes: @commitment.notes, position: @commitmentn, role: @commitmentole_count: @commitment.role_count, role_name: @commitment.role_name, commitment_kind: @commitmentnd, taxbranch_id: @commitmentresoutepch_id, urgency: @commitment.urgency } }
    assert_redirected_to commitment_url(@commitment)
  end

  test "should destroy commitment" do
    assert_difference("Commitment.count", -1) do
      delete commitment_url(@commitment)
    end

    assert_redirected_to commitments_url
  end
end
