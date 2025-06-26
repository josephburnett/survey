require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as_user_one
  end
  test "should get create" do
    post section_questions_path(sections(:one)), params: { question: { name: "Test Question", question_type: "string" } }
    assert_response :redirect
  end
end
