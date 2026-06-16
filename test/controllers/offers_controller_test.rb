require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    listing = listings(:one)
    get listing_offers_url(listing)
    assert_response :success
  end
end
