class OffersController < ApplicationController
  before_action :require_contractor, only: [ :new, :create ] # ADDED
  def index
    if current_user.role == "customer"
      @offers = Offer.where(listing: current_user.listings)
    else
      @offers = current_user.offers
    end
  end

  def declined
  @listing = Listing.find(params[:listing_id])
  @offers = @listing.offers.where(offer_status: "declined")
  end

  def new
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.new
  end

  def create
    @listing = Listing.find(params[:listing_id])
    @offer = @listing.offers.new(offer_params)
    @offer.user = current_user

    if @offer.save
      redirect_to listing_offer_path(@listing, @offer), notice: "Offer submitted!"
    else
      render :new, status: :unprocessable_entity
    end
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

  private

  def require_contractor # ADDED
    unless current_user.role == "contractor"
      redirect_to root_path, alert: "Only contractors can create offers."
    end
  end

  def offer_params
    params.require(:offer).permit(:quote, :note, :estimated_duration_hours, :suggested_date_and_time)
  end
end
