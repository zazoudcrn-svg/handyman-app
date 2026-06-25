class BookingsController < ApplicationController
  before_action :set_booking, only: [ :show, :edit, :update, :destroy, :accept_date, :complete, :cancel_booking ]
  before_action :authenticate_user!

# CUSTOMER or CONTRACTOR: See all bookings
def index
  # 1. Load ALL bookings first
  if current_user.customer?
    @all_bookings = Booking.where(listing_id: current_user.listings.pluck(:id))
  else
    @all_bookings = Booking.joins(:offer).where(offers: { user_id: current_user.id })
  end

  # 2. Start @bookings as a copy (for filtering only)
  @bookings = @all_bookings

  # 3. STATUS FILTER (affects ONLY @bookings)
  if params[:status].present?
    case params[:status]
    when "confirmed"
      @bookings = @bookings.where(booking_status: [ "confirmed", "pending", "date_change_requested" ])
    when "cancelled"
      @bookings = @bookings.where(booking_status: "cancelled")
    when "completed"
      @bookings = @bookings.where(booking_status: "completed")
    end
  end

  # 4. CALENDAR should ALWAYS use ALL confirmed bookings
  @calendar_bookings = @all_bookings.where(booking_status: "confirmed")

  # ⭐5. NEW: Sort all bookings by scheduled date
  @all_bookings = @all_bookings.order(:scheduled_date_and_time)
end

  # CUSTOMER: View booking details
  def show
    @booking = Booking.find(params[:id])
    @listing = @booking.listing
    @offer = @booking.offer
    @messages = @offer.messages.order(:created_at)
    @message = Message.new

    if params[:accepted] == "true"
      if current_user.customer?
        flash[:notice] = "The customer accepted the contractor proposed date."
      elsif current_user.contractor?
        flash[:notice] = "The contractor accepted the customer proposed date."
      end

      # ⭐ Redirect to clean URL so message doesn't repeat on refresh
      redirect_to booking_path(@booking) and return
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



  def complete
    if current_user.customer? || current_user.contractor?
      @booking.update(booking_status: "completed")

      # Notify both parties that the booking is completed
      NotificationJob.perform_later("booking_completed", @booking.contractor, @booking)
      NotificationJob.perform_later("booking_completed", @booking.customer, @booking)
      redirect_to @booking, notice: "Booking marked as completed."
    else
      redirect_to bookings_path, alert: "You are not allowed to complete this booking."
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



  def cancel_booking
  @booking = Booking.find(params[:id])
  @booking.update(
    booking_status: "cancelled",
    cancellation_note: params[:booking][:cancellation_note],
    cancelled_by: current_user.role
  )

  # Notify both parties
  NotificationJob.perform_later("booking_cancelled", @booking.contractor, @booking)
  NotificationJob.perform_later("booking_cancelled", @booking.customer, @booking)

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
    @listing = @booking.listing
  end
end
