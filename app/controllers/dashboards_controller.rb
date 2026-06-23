class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    cookies.permanent[:has_account] = "true"

    if current_user.contractor_profile.present?
      profile = current_user.contractor_profile
      contractor_category_ids = current_user.categories.pluck(:id)

      # Use max_distance param if provided, otherwise fall back to their travel radius
      radius = params[:max_distance].present? ? params[:max_distance].to_i : profile.travel_radius

      # Base query
      if current_user.latitude.present? && current_user.longitude.present?
        matching_listings = Listing.near([current_user.latitude, current_user.longitude], radius, units: :km)
                                  .where(category_id: contractor_category_ids)
      else
        matching_listings = Listing.where(category_id: contractor_category_ids)
      end

      # Exclude declined and already-offered listings
      @available_listings = matching_listings
        .where.not(id: current_user.declined_listings.select(:listing_id))
        .where.not(id: current_user.offers.select(:listing_id))

      # Category filter
      if params[:category_ids].present?
        @available_listings = @available_listings.where(category_id: params[:category_ids])
      end

      # Urgency filter
      if params[:urgency].present?
        @available_listings = @available_listings.where(urgency: params[:urgency])
      end

      # Availability filter
      if params[:availability_profile].present?
        @available_listings = @available_listings.where(availability_profile: params[:availability_profile])
      end

      # Sorting
      if params[:sort_by] == "date"
        @available_listings = @available_listings.reorder(created_at: :desc)
      elsif params[:sort_by] == "distance"
        # .near already orders by distance — do nothing
      else
        @available_listings = @available_listings.reorder(Arel.sql("CASE WHEN title LIKE '%EMERGENCY%' THEN 0 ELSE 1 END"))
      end

      render :contractor_show

    else
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
