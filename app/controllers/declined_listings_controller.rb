class DeclinedListingsController < ApplicationController
  before_action :authenticate_user!

  def create
    @listing = Listing.find(params[:listing_id])

    # Securely find or create the decline record for the current user
    current_user.declined_listings.find_or_create_by!(listing: @listing)

    flash[:notice] = "The listing has been hidden from your feed."

    # Redirect back to the dashboard / contractor home feed
    redirect_back fallback_location: root_path
  end
end
