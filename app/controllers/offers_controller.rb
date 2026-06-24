class OffersController < ApplicationController
  before_action :require_contractor, only: [ :new, :create, :edit, :update ] # ADDED
  before_action :set_listing_and_offer, only: [:show, :edit, :update]
  before_action :authorize_offer_owner!, only: [:edit, :update]

  def index
    if current_user.role == "customer"
      @offers = Offer.where(listing: current_user.listings)

      # Listing filter
      if params[:listing_id].present?
        @offers = @offers.where(listing_id: params[:listing_id])
      end
    else
      @offers = current_user.offers
    end

    # Status filter — default to pending
    if params[:status] == "accepted"
      @offers = @offers.where(offer_status: "accepted")
    elsif params[:status] == "declined"
      @offers = @offers.where(offer_status: "declined")
    else
      @offers = @offers.where(offer_status: [nil, "pending"])
    end

    # Sorting
    if params[:sort_by] == "quote_asc"
      @offers = @offers.order(quote: :asc)
    elsif params[:sort_by] == "quote_desc"
      @offers = @offers.order(quote: :desc)
    else
      @offers = @offers.order(created_at: :desc)
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
    @offer.offer_status = "pending"

    if @offer.save
      redirect_to listing_offer_path(@listing, @offer), notice: "Offer submitted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @offer.update(offer_params)
      redirect_to listing_offer_path(@listing, @offer), notice: "Offer updated successfully."
    else
      render :edit, status: :unprocessable_entity
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

  def destroy
    @listing = Listing.find(params[:listing_id])
    @offer = Offer.find(params[:id])

    if @offer.user == current_user
      @offer.destroy
      redirect_to offers_path, notice: "Offer cancelled successfully."
    else
      redirect_to listing_offer_path(@listing, @offer), alert: "You are not authorized to do that."
    end
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

  def set_listing_and_offer
  @listing = Listing.find(params[:listing_id])
  @offer = Offer.find(params[:id])
  end

  def authorize_offer_owner!
    unless @offer.user == current_user
      redirect_to listing_offer_path(@listing, @offer), alert: "You are not authorized to do that."
    end
  end
end
