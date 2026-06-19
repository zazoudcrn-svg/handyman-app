class DashboardsController < ApplicationController
  def show
    # Check if the logged-in user has a contractor profile setup
    if current_user.contractor_profile.present?
      # 1. Contractor Logic
      profile = current_user.contractor_profile

      # Step 1: Get all category IDs the contractor specializes in
      contractor_category_ids = current_user.categories.pluck(:id)

      # Step 2: Filter listings by radius AND matching categories
      @listings = Listing.near(current_user, profile.travel_radius, units: :km)
                         .where(category_id: contractor_category_ids)

      render :contractor_show
    else
      # 2. Customer Logic
      # Fetch only the listings created by this specific customer
      @listings = current_user.listings
      render :customer_show
    end
  end
end
