class OffersController < ApplicationController
  def index
    @listing = Listing.find(params[:listing_id])
    @offers = @listing.offers
  end
  def show
    @offer = Offer.find(params[:id])
  end
end
