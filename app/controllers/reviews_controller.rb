class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_booking, only: [:new, :create]

  def index
    @received_reviews = Review.where(reviewee_id: current_user.id)
    @sent_reviews = Review.where(user_id: current_user.id)
  end

  def new
    @review = Review.new
  end

  def create
    unless @booking.listing.user == current_user || @booking.offer.user == current_user
      redirect_to new_review_path, alert: "Not authorized."
      return
    end

    unless @booking.booking_status == "completed"
      redirect_to new_review_path, alert: "Booking needs to be marked as completed to submit a review."
      return
    end

    if Review.exists?(user_id: current_user.id, booking_id: @booking.id)
      redirect_to new_review_path, alert: "You have already reviewed this booking."
      return
    end

    @review = Review.new(review_params)
    @review.booking = @booking
    @review.user = current_user
    @review.reviewee = current_user == @booking.listing.user ? @booking.offer.user : @booking.listing.user

    if @review.save
      # Notify reviewee
      NotificationJob.perform_later("new_review", @review.reviewee, @review)
      redirect_to booking_path(@booking), notice: "Review submitted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:review).permit(
      :rating,
      :content
    )
  end

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end
end
