class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_contractor_profile

  def show
    @reviews = @user.reviews_received.order(created_at: :desc)
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
    @contractor_profile = @user.contractor_profile if @user.role == "contractor"
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :street, :city, :postcode, :country,
      contractor_profile_attributes: [
        :id, :business_name, :street, :city, :postcode, :country,
        :travel_radius, :start_time, :end_time, :weekday_availability, :google_business_profile
      ]
    )
  end
end
