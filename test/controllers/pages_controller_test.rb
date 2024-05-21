require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get chatbot" do
    get pages_chatbot_url
    assert_response :success
  end
end
