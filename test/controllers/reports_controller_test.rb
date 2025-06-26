require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_one
  end
  test "should get index" do
    get reports_path
    assert_response :success
  end

  test "should get show" do
    get report_path(reports(:one))
    assert_response :success
  end

  test "should get new" do
    get new_report_path
    assert_response :success
  end

  test "should get create" do
    post reports_path, params: {
      report: { name: "Test Report", time_of_day: "09:00", interval_type: "weekly" },
      interval_config: { days: [ "monday" ] }
    }
    assert_response :redirect
  end

  test "should get edit" do
    get edit_report_path(reports(:one))
    assert_response :success
  end

  test "should get update" do
    patch report_path(reports(:one)), params: { report: { name: "Updated Report", time_of_day: "10:00", interval_type: "weekly", interval_config: { days: [ "tuesday" ] } } }
    assert_response :redirect
  end

  test "should get soft_delete" do
    patch soft_delete_report_path(reports(:one))
    assert_response :redirect
  end
end
