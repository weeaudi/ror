require "test_helper"

class AdminsControllerTest < ActionDispatch::IntegrationTest
  test "should get refresh" do
    get admins_refresh_url
    assert_response :success
  end
end
