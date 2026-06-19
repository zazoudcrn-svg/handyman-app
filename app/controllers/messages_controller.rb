class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing
  before_action :set_offer

  def create
    @message = @offer.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_back fallback_location: listing_offer_path(@listing, @offer), notice: "Message sent."
    else
      redirect_back fallback_location: listing_offer_path(@listing, @offer), alert: "Message could not be sent. Please try again."
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def set_offer
    @offer = @listing.offers.find(params[:offer_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
