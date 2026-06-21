class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    # Set a permanent cookie to remember this device has an active account
    cookies.permanent[:has_account] = "true"

    # Check if the logged-in user has a contractor profile setup
    if current_user.contractor_profile.present?
      # 1. Contractor Logic
      profile = current_user.contractor_profile

      # Step 1: Get all category IDs the contractor specializes in
      contractor_category_ids = current_user.categories.pluck(:id)

      # Step 2: Filter listings by radius AND matching categories (with safety fallback for skip onboarding)
      if current_user.latitude.present? && current_user.longitude.present?
        matching_listings = Listing.near([current_user.latitude, current_user.longitude], profile.travel_radius, units: :km)
                                   .where(category_id: contractor_category_ids)
      else
        # Fallback: If onboarding was skipped, show all listings matching the contractor's categories without radius filter
        matching_listings = Listing.where(category_id: contractor_category_ids)
      end

      # Tab 1: Available Listings
      # Filters out jobs that the contractor has already declined or submitted an offer for.
      # Orders emergency listings to the top of the list.
      @available_listings = matching_listings.where.not(id: current_user.declined_listings.select(:listing_id))
                                              .where.not(id: current_user.offers.select(:listing_id))
                                              .order(Arel.sql("CASE WHEN title LIKE '%EMERGENCY%' THEN 0 ELSE 1 END"))

      # Tab 2: My Pending Offers
      # Fetches jobs where an offer was submitted, but no booking exists yet.
      @offered_listings = matching_listings.where(id: current_user.offers.select(:listing_id))
                                            .left_outer_joins(offers: :booking)
                                            .where(bookings: { id: nil })

      # Tab 3: Ongoing Bookings
      # Fetches active, confirmed bookings for this specific contractor that are not yet finished.
      @ongoing_bookings = matching_listings.joins(offers: :booking)
                                           .where(offers: { user_id: current_user.id }, bookings: { booking_status: "confirmed" })

      # Tab 4: Completed Bookings
      # Fetches past bookings that have been successfully marked as completed.
      @completed_bookings = matching_listings.joins(offers: :booking)
                                             .where(offers: { user_id: current_user.id }, bookings: { booking_status: "completed" })

      # Tab 5: Archived / Declined Listings
      # Fetches jobs that the contractor actively decided to hide or decline.
      @archived_listings = matching_listings.where(id: current_user.declined_listings.select(:listing_id))

      # NEW FOR CALENDAR: Fetch both confirmed and completed bookings to display them in the schedule grid
      @bookings = Booking.joins(offer: :user)
                         .where(offers: { user_id: current_user.id }, booking_status: ["confirmed", "completed"])

      render :contractor_show
    else
      # 2. Customer Logic
      # Fetch only the listings created by this specific customer
      @listings = current_user.listings
      render :customer_show
    end
  end
end
