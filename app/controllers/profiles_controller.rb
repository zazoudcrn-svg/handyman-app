class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_contractor_profile
  before_action :authorize_own_profile!, only: [:edit, :update]

  def show
    @back_path = (request.referer.present? && !request.referer.include?('/profiles/')) ? request.referer : dashboard_path
    @is_own_profile = current_user == @user
    @reviews = @user.reviews_received.includes(:user).order(created_at: :desc)
    @avg_rating = @reviews.average(:rating)&.round(1)

    if @user.contractor?
      @jobs_completed = @user.offers.joins(:booking)
                            .where(bookings: { booking_status: "completed" }).count
    else
      @jobs_posted = @user.listings.count
    end
  end
  def edit
  end

  def update
    if @user.update_without_password(user_params)
      redirect_to profile_path(@user), notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_contractor_profile
    @contractor_profile = @user.contractor_profile if @user.contractor?
  end

  def authorize_own_profile!
    unless current_user == @user
      redirect_to profile_path(@user), alert: "You are not authorized to do that."
    end
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :street, :city, :postcode, :country,
      :bio, :avatar,
      contractor_profile_attributes: [
        :id, :business_name, :street, :city, :postcode, :country,
        :travel_radius, :start_time, :end_time, :weekday_availability, :google_business_profile
      ]
    )
  end
end
