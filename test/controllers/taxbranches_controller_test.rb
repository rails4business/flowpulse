require "test_helper"

class TaxbranchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @taxbranch = taxbranches(:one)
  end

  test "should get index" do
    get taxbranches_url
    assert_response :success
  end

  test "should get new" do
    get new_taxbranch_url
    assert_response :success
  end

  test "should create taxbranch" do
    assert_difference("Taxbranch.count") do
      post taxbranches_url, params: { taxbranch: { ancestry: @taxbranch.ancestry, lead_id: @taxbranch.lead_id, meta: @taxbranch.meta, notes: @taxbranch.notes, position: @taxbranch.position, slug: @taxbranch.slug, slug_category: @taxbranch.slug_category, slug_label: @taxbranch.slug_label } }
    end

    assert_redirected_to taxbranch_url(Taxbranch.last)
  end

  test "should show taxbranch" do
    get taxbranch_url(@taxbranch)
    assert_response :success
  end

  test "should get edit" do
    get edit_taxbranch_url(@taxbranch)
    assert_response :success
  end

  test "should update taxbranch" do
    patch taxbranch_url(@taxbranch), params: { taxbranch: { ancestry: @taxbranch.ancestry, lead_id: @taxbranch.lead_id, meta: @taxbranch.meta, notes: @taxbranch.notes, position: @taxbranch.position, slug: @taxbranch.slug, slug_category: @taxbranch.slug_category, slug_label: @taxbranch.slug_label } }
    assert_redirected_to taxbranch_url(@taxbranch)
  end

  test "should destroy taxbranch" do
    assert_difference("Taxbranch.count", -1) do
      delete taxbranch_url(@taxbranch)
    end

    assert_redirected_to taxbranches_url
  end
end
