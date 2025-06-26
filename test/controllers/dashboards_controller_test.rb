require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_one
  end
  test "should get index" do
    get dashboards_path
    assert_response :success
  end

  test "should get show" do
    get dashboard_path(dashboards(:one))
    assert_response :success
  end

  test "should get new" do
    get new_dashboard_path
    assert_response :success
  end

  test "should get edit" do
    get edit_dashboard_path(dashboards(:one))
    assert_response :success
  end

  test "should get create" do
    post dashboards_path, params: { dashboard: { name: 'Test Dashboard' } }
    assert_response :redirect
  end

  test "should get update" do
    patch dashboard_path(dashboards(:one)), params: { dashboard: { name: 'Updated Dashboard' } }
    assert_response :redirect
  end

  test "should get soft_delete" do
    patch soft_delete_dashboard_path(dashboards(:one))
    assert_response :redirect
  end
end
