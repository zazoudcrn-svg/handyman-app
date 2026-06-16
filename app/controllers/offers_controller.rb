class OffersController < ApplicationController
  def index
    @listing = Listing.find(params[:listing_id])
    @offers = @listing.offers
  end
  def show
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.find(params[:id])
    @message = Message.new
  end

  def accept
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.find(params[:id])
    @offer.update(offer_status: "accepted")
    redirect_to listing_offer_path(@listing, @offer), notice: "Offer accepted!"
  end

  def decline
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.find(params[:id])
    @offer.update(offer_status: "declined")
    redirect_to listing_offer_path(@listing, @offer), notice: "Offer declined!"
  end
end
