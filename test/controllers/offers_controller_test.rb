require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "should get index" do
    user = users(:one)
    sign_in user

    listing = listings(:one)
    get listing_offers_url(listing)
    assert_response :success
  end
end
