require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get new" do
    get new_listing_url
    assert_response :success
  end

  test "should get create" do
    post listings_url, params: { listing: { title: "Test Listing", description: "Test Description" } }
    assert_response :redirect
  end
end
