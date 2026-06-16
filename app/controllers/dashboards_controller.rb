class DashboardsController < ApplicationController
  def show
    # Check if the logged-in user has a contractor profile setup
    if current_user.contractor_profile.present?
      # 1. Contractor Logic
      # For now, we load all listings so they have something to see
      @listings = Listing.all
      render :contractor_show
    else
      # 2. Customer Logic
      # Fetch only the listings created by this specific customer
      @listings = current_user.listings
      render :customer_show
    end
  end
end
