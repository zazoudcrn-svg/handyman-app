class BookingsController < ApplicationController
  before_action :set_booking, only: [ :show, :propose_date, :accept_date, :complete ]
  before_action :authenticate_user!

# CUSTOMER: See all bookings
def index
  if current_user
    @bookings = Booking.where(listing_id: current_user.listings.pluck(:id))

    if params[:status].present?
      if params[:status] == "pending_declined"
        @bookings = @bookings.where(booking_status: [ :pending, :declined ])
      else
        @bookings = @bookings.where(booking_status: params[:status])
      end
    end
  else
    @bookings = []
  end
end



  # CUSTOMER: View booking details
  def show
  end

  # CUSTOMER: Propose a new date
  def propose_date
    @booking.update(
      new_proposed_date_and_time: params[:booking][:new_proposed_date_and_time],
      proposed_by: "customer",
      booking_status: "date_change_requested"
    )
    redirect_to booking_path(@booking), notice: "New date proposed successfully"
  end

  # CUSTOMER: Accept contractor's proposed date
  def accept_date
    @booking.update(
      scheduled_date_and_time: @booking.new_proposed_date_and_time,
      new_proposed_date_and_time: nil,
      proposed_by: nil,
      booking_status: "confirmed"
    )
    redirect_to @booking, notice: "New date accepted."
  end

  # CUSTOMER: Mark booking as completed
  def complete
    @booking = Booking.find(params[:id])
    @booking.update(booking_status: :completed)
    redirect_to booking_path(@booking)
  end

def cancel_booking
  @booking = Booking.find(params[:id])

  @booking.update(
    booking_status: "cancelled",
    cancellation_note: params[:booking][:cancellation_note],
  )

  redirect_to booking_path(@booking), notice: "Booking cancelled successfully"
end


  private

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
