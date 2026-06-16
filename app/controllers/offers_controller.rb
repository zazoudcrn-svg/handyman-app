class OffersController < ApplicationController
  def index
    @listing = Listing.find(params[:listing_id])
    @offers = @listing.offers
  end
end
