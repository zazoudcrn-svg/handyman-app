class OnboardingsController < ApplicationController
  before_action :authenticate_user!

  # 1. GET /onboarding/customer
  def customer
    @user = current_user
  end

  # 2. PATCH /onboarding/customer_update
  def customer_update
    if current_user.update(customer_params)
      redirect_to root_path, notice: "Welcome! Your profile has been successfully set up."
    else
      render :customer, status: :unprocessable_entity
    end
  end

  # 3. GET /onboarding/contractor
  def contractor
    @contractor_profile = current_user.contractor_profile || current_user.build_contractor_profile
  end

  # 4. POST /onboarding/contractor_create
  def contractor_create
    @contractor_profile = current_user.build_contractor_profile(contractor_params)

    if params[:contractor_profile][:category_ids].present?
      params[:contractor_profile][:category_ids].each do |cat_id|
        @contractor_profile.user.specialties.build(category_id: cat_id)
      end
    end

    if @contractor_profile.save
      if params[:contractor_profile][:user_attributes].present?
        current_user.update(user_base_params)
      end
      redirect_to root_path, notice: "Profile successfully set up! Your contractor dashboard is ready."
    else
      render :contractor, status: :unprocessable_entity
    end
  end

  private

  def customer_params
    params.require(:user).permit(:first_name, :last_name, :street, :postcode, :city, :country)
  end

  def contractor_params
    params.require(:contractor_profile).permit(
      :business_name, :google_business_profile, :street, :postcode, :city, :country,
      :travel_radius, :weekday_availability, :start_time, :end_time
    )
  end

  def user_base_params
    params.require(:contractor_profile).require(:user_attributes).permit(:first_name, :last_name)
  end
end
