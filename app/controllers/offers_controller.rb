class OffersController < ApplicationController
  def index
  @listing = Listing.find(params[:listing_id])
  @offers = @listing.offers.where(offer_status: [ nil, "pending", "accepted" ])
  end

  def declined
  @listing = Listing.find(params[:listing_id])
  @offers = @listing.offers.where(offer_status: "declined")
  end

  def show
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.find(params[:id])
    @messages = @offer.messages.order(created_at: :asc)
    @message = Message.new
  end

  def accept
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.find(params[:id])
    @offer.update(offer_status: "accepted")
    redirect_to booking_path(@offer.booking), notice: "Offer accepted!"
  end

  def decline
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.find(params[:id])
    @offer.update(offer_status: "declined")
    redirect_to listing_offers_path(@listing), notice: "The offer has been declined" # CHANGED
  end
end
