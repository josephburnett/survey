require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_path
    assert_response :success
  end

  test "should get create" do
    post sessions_path, params: { name: users(:one).name, password: "password" }
    assert_response :redirect
  end

  test "should get destroy" do
    delete logout_path
    assert_response :redirect
  end
end
