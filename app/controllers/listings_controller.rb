class ListingsController < ApplicationController
  before_action :authenticate_user!
  # SENIOR FIX: Extended to ensure only the customer who owns the listing can edit/update/destroy it
  before_action :ensure_customer, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :ensure_onboarding_completed, only: [:new, :create]

  def new
    # Initialize a clean, empty instance for the form
    @listing = Listing.new
  end

  def create
    # Instantiate the new listing with permitted parameters
    @listing = Listing.new(listing_params)
    # Associate the listing with the logged-in user
    @listing.user = current_user

    # Optional: Set a default status if your model doesn't handle it yet
    @listing.listing_status = "open"

    if @listing.save
      # Redirect to dashboard with a success flash message
      redirect_to dashboard_path, notice: "Your job listing was successfully posted!"
    else
      # Render the form again with error messages if validation fails
      render :new, status: :unprocessable_entity
    end
  end

  # GET /listings/:id
  def show
    @listing = Listing.find(params[:id])
  end

  # 1. GET /listings/:id/edit
  def edit
    @listing = current_user.listings.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You are not authorized to edit this listing."
  end

  # 2. PATCH/PUT /listings/:id
  def update
    @listing = current_user.listings.find(params[:id])
    if @listing.update(listing_params)
      redirect_to dashboard_path, notice: "Your job listing was successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You are not authorized to update this listing."
  end

  # 3. DELETE /listings/:id
  def destroy
    @listing = current_user.listings.find(params[:id])
    @listing.destroy
    redirect_to dashboard_path, notice: "Your job listing was successfully deleted!"
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "You are not authorized to delete this listing."
  end

  private

  def ensure_onboarding_completed
    if current_user.city.blank?
      redirect_to onboarding_customer_path, alert: "Please complete your profile details before creating a project request!"
    end
  end

  def listing_params
    # Whitelist accepted attributes including category, address fields, multiple photos, and availability
    params.require(:listing).permit(
      :title,
      :description,
      :category_id,
      :postcode,
      :city,
      :street,
      :preferred_date_and_time,
      :availability_profile,
      :urgency,
      photos: [],
      ai_answers: {}
    )
  end

  def ensure_customer
    # Check the role string directly to see if the user is a contractor
    if current_user.role == "contractor"
      redirect_to dashboard_path, alert: "Only customers can manage job listings!"
    end
  end
end
