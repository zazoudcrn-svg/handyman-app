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

      # Step 2: Filter listings by radius AND matching categories
      if current_user.latitude.present? && current_user.longitude.present?
        matching_listings = Listing.near([current_user.latitude, current_user.longitude], profile.travel_radius, units: :km)
                                   .where(category_id: contractor_category_ids)
      else
        # Fallback: If onboarding was skipped, show all listings matching the contractor's categories
        matching_listings = Listing.where(category_id: contractor_category_ids)
      end

      # Tab 1: Active Listings (Available jobs)
      @available_listings = matching_listings.where.not(id: current_user.declined_listings.select(:listing_id))
                                              .where.not(id: current_user.offers.select(:listing_id))
                                              .order(Arel.sql("CASE WHEN title LIKE '%EMERGENCY%' THEN 0 ELSE 1 END"))

      # Tab 2: Pending Offers
      @offered_listings = matching_listings.where(id: current_user.offers.select(:listing_id))
                                            .left_outer_joins(offers: :booking)
                                            .where(bookings: { id: nil })

      # Tab 3: Ongoing Bookings
      @ongoing_bookings = matching_listings.joins(offers: :booking)
                                           .where(offers: { user_id: current_user.id }, bookings: { booking_status: "confirmed" })

      # Tab 4: Completed Bookings
      @completed_bookings = matching_listings.joins(offers: :booking)
                                             .where(offers: { user_id: current_user.id }, bookings: { booking_status: "completed" })

      # Tab 5: Declined Listings
      @archived_listings = matching_listings.where(id: current_user.declined_listings.select(:listing_id))

      render :contractor_show
    else
      # 2. Customer Logic
      @listings = current_user.listings
      render :customer_show
    end
  end

  # NEW: Separate method for the calendar view
  def calendar
    # Fetch confirmed and completed bookings specifically for the current contractor
    @bookings = Booking.joins(offer: :user)
                       .where(offers: { user_id: current_user.id }, booking_status: ["confirmed", "completed"])

    # Rails will automatically render app/views/dashboards/calendar.html.erb
  end
end
