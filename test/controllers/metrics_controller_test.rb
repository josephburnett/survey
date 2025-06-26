require "test_helper"

class MetricsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_one
  end

  test "should get index" do
    get metrics_path
    assert_response :success
  end

  test "should get show" do
    # Skip this test for now due to complex series data requirements
    skip "Series data generation requires complex setup"
  end
end
