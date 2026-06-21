class OnboardingsController < ApplicationController
  before_action :authenticate_user!

  # 1. GET /onboarding/customer
  def customer
  @user = current_user
  end

  # 2. PATCH /onboarding/customer_update
  def customer_update
    if current_user.update(customer_params)
      redirect_to dashboard_path, notice: "Welcome! Your profile has been successfully set up."
    else
      render :customer, status: :unprocessable_entity
    end
  end

  # 3. GET /onboarding/contractor
  def contractor
    @contractor_profile = current_user.contractor_profile || current_user.build_contractor_profile
  end

  # 4. PATCH /onboarding/contractor_update
  def contractor_update
    # Fetch existing profile or build a new one linked to the current user
    @contractor_profile = current_user.contractor_profile || current_user.build_contractor_profile

    # Safely extract nested user parameters from the form payload
    user_attrs = params[:contractor_profile][:user] if params[:contractor_profile]

    # Process all database inserts within a single atomic transaction
    ActiveRecord::Base.transaction do
      # 1. Update personal identity and business location address in users table
      if user_attrs.present?
        current_user.update!(
          first_name: user_attrs[:first_name],
          last_name: user_attrs[:last_name],
          street: user_attrs[:street],
          postcode: user_attrs[:postcode],
          city: user_attrs[:city],
          country: user_attrs[:country]
        )
      end

      # 2. Update contractor profile logistics, hours, and marketing fields
      @contractor_profile.update!(contractor_params)

      # 3. Synchronize Step 2 category selections with the specialties join table
      current_user.specialties.destroy_all
      if params[:category_ids].present?
        params[:category_ids].each do |category_id|
          current_user.specialties.create!(category_id: category_id)
        end
      end
    end

    # Redirect to contractor dashboard upon successful database validation
    redirect_to dashboard_path, notice: "Welcome! Your professional business profile is fully set up."
  rescue ActiveRecord::RecordInvalid => e
    # Catch any validation errors, expose the message, and re-render step 5 with code 422
    flash.now[:alert] = "Onboarding failed: #{e.message}"
    render :contractor, status: :unprocessable_entity
  end

  # 5. PATCH /skip_onboarding
  def skip
    # Wir setzen das Flag beim eingeloggten User auf true
    current_user.update(onboarding_skipped: true)

    # Und leiten ihn direkt zum zentralen Dashboard weiter
    redirect_to dashboard_path, notice: "You can complete your profile anytime later!"
  end

  private

  def customer_params
    params.require(:user).permit(:first_name, :last_name, :street, :postcode, :city, :country)
  end

  # Strong parameters matching the database schema for contractor profiles
  def contractor_params
    params.require(:contractor_profile).permit(
      :business_name,
      :travel_radius,
      :weekday_availability,
      :start_time,
      :end_time,
      :google_business_profile
    )
  end
end
