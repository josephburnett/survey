require "test_helper"

class ResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_one
  end
  test "should get index" do
    get responses_path
    assert_response :success
  end

  test "should get show" do
    get response_path(responses(:one))
    assert_response :success
  end
end
