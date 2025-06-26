require "test_helper"

class SectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_one
  end
  test "should get index" do
    get sections_path
    assert_response :success
  end
end
