class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    # Check if the logged-in user has a contractor profile setup
    if current_user.contractor_profile.present?
      # 1. Contractor Logic
      profile = current_user.contractor_profile

      # Step 1: Get all category IDs the contractor specializes in
      contractor_category_ids = current_user.categories.pluck(:id)

      # Step 2: Filter listings by radius AND matching categories
      matching_listings = Listing.near(current_user, profile.travel_radius, units: :km)
                                 .where(category_id: contractor_category_ids)

      # Tab 1: Available (No decline record AND no offer submitted yet)
      # Senior Feature: Sorts EMERGENCY titles automatically to the very top via SQL
      @available_listings = matching_listings.where.not(id: current_user.declined_listings.select(:listing_id))
                                              .where.not(id: current_user.offers.select(:listing_id))
                                              .order(Arel.sql("CASE WHEN title LIKE '%EMERGENCY%' THEN 0 ELSE 1 END"))

      # Tab 2: My Offers (Offer submitted BUT no booking confirmed yet)
      @offered_listings = matching_listings.where(id: current_user.offers.select(:listing_id))
                                            .left_outer_joins(offers: :booking)
                                            .where(bookings: { id: nil })

      # Tab 3: My Bookings (An offer resulted in a confirmed booking)
      @booked_listings = matching_listings.joins(offers: :booking)
                                           .where(offers: { user_id: current_user.id })

      # Tab 4: Archived / Declined (Explicitly hidden by the contractor)
      @archived_listings = matching_listings.where(id: current_user.declined_listings.select(:listing_id))

      render :contractor_show
    else
      # 2. Customer Logic
      # Fetch only the listings created by this specific customer
      @listings = current_user.listings
      render :customer_show
    end
  end
end
