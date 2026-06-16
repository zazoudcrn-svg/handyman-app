require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get show" do
    user = users(:one)
    sign_in user

    get dashboard_url
    assert_response :success
  end
end
