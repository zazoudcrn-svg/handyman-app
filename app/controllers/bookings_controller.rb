class BookingsController < ApplicationController
  before_action :set_booking, only: [ :show, :edit, :update, :destroy, :accept_date, :complete, :cancel_booking ]
  before_action :authenticate_user!

# CUSTOMER or CONTRACTOR: See all bookings
def index
  if current_user.customer?
    # Customer sees bookings for their own listings
    @bookings = Booking.where(listing_id: current_user.listings.pluck(:id))
  else
    # Contractor sees bookings for offers they made
    @bookings = Booking.joins(:offer).where(offers: { user_id: current_user.id })
  end

   # Status filtering (works for both roles)
   if params[:status].present?
  case params[:status]
  when "confirmed"
    @bookings = @bookings.where(booking_status: [ :pending, :confirmed, :date_change_requested ])
  else
    @bookings = @bookings.where(booking_status: params[:status])
  end
   end
end


  # CUSTOMER: View booking details
  def show
    @booking = Booking.find(params[:id])
    @offer = @booking.offer
    @messages = @offer.messages.order(:created_at)
    @message = Message.new
    if params[:accepted] == "true"
    if current_user.customer?
      flash.now[:notice] = "The customer accepted the contractor proposed date."
    elsif current_user.contractor?
      flash.now[:notice] = "The contractor accepted the customer proposed date."
    end
    end
  end

def edit
  @booking = Booking.find(params[:id])
  @booking.build_listing unless @booking.listing
end

def update
  @booking = Booking.find(params[:id])

  case params[:booking][:form_type]

  when "propose_date"
    # your propose date logic stays the same
    @booking.new_proposed_date_and_time = params[:booking][:new_proposed_date_and_time]
    @booking.booking_status = "date_change_requested"
    @booking.proposed_by = current_user.role

    if @booking.save
      redirect_to edit_booking_path(@booking), notice: "New date proposed successfully."
    else
      redirect_to edit_booking_path(@booking), alert: "Something went wrong."
    end

  when "save_changes"
    if @booking.update(booking_params)
      render turbo_stream: turbo_stream.update(
        "status_message",
        "<div class='alert alert-success mt-3'>Booking updated successfully.</div>"
      )
    else
      render :edit, status: :unprocessable_entity
    end
  end
end




  def destroy
   @booking = Booking.find(params[:id])
   @booking.destroy
   redirect_to bookings_path, notice: "Booking deleted successfully."
  end


# CUSTOMER or CONTRACTOR: Propose a new date
def propose_date
  @booking = Booking.find(params[:id])

  if params[:booking][:new_proposed_date_and_time].present?
    @booking.new_proposed_date_and_time = params[:booking][:new_proposed_date_and_time]
    @booking.booking_status = "date_change_requested"
    @booking.proposed_by = current_user.role
  end

  if @booking.save
    redirect_to edit_booking_path(@booking), notice: "New date proposed successfully."
  else
    redirect_to edit_booking_path(@booking), alert: "Something went wrong."
  end
end


  # CUSTOMER or CONTRACTOR: Accept new date
  def accept_date
    @booking.update(
      scheduled_date_and_time: @booking.new_proposed_date_and_time,
      new_proposed_date_and_time: nil,
      accepted_by: current_user.role,
      proposed_by: nil,
      booking_status: "confirmed"
    )
    redirect_to booking_path(@booking, accepted: true)
  end

  # CUSTOMER or CONTRACTOR: Mark booking as completed
  def complete
  if current_user.customer? || current_user.contractor?
    @booking.update(booking_status: "completed")
    redirect_to @booking, notice: "Booking marked as completed."
  else
    redirect_to bookings_path, alert: "You are not allowed to complete this booking."
  end
  end

def cancel_booking
  @booking = Booking.find(params[:id])

  @booking.update(
    booking_status: "cancelled",
    cancellation_note: params[:booking][:cancellation_note],
    cancelled_by: current_user.role
  )

  redirect_to bookings_path, notice: "Booking cancelled successfully"
end


  private

  def booking_params
    params.require(:booking).permit(
      :new_proposed_date_and_time,
      listing_attributes: [ :id, :street, :city, :postcode, :country ]
    )
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
