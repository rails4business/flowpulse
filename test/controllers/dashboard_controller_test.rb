require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get dashboard_home_url
    assert_response :success
  end

  test "should get superadmin" do
    get dashboard_superadmin_url
    assert_response :success
  end
end
