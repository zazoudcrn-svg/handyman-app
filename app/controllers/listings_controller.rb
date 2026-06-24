class ListingsController < ApplicationController
  before_action :authenticate_user!
  # Extended to ensure only the customer who owns the listing can edit/update/destroy it
  before_action :ensure_customer, only: [:new, :create, :edit, :update, :destroy]
  before_action :ensure_onboarding_completed, only: [:new, :create]

  def new
    # Initialize a clean, empty instance for the form
    @listing = Listing.new
  end

  def create
    logger.debug "DEBUG PARAMS: #{params[:listing].to_unsafe_h.inspect}"
    # 1. Clean the parameters before creating the object.
    # If the photos array contains only blank strings (or is empty),
    # we remove the key from params to prevent ActiveStorage from creating empty attachments.
    if params[:listing][:photos].is_a?(Array)
      params[:listing][:photos].reject!(&:blank?)
      params[:listing].delete(:photos) if params[:listing][:photos].empty?
    end

    # 2. Instantiate the new listing with permitted parameters
    @listing = Listing.new(listing_params)

    # 3. Associate the listing with the logged-in user
    @listing.user = current_user

    # 4. Set a default status
    @listing.listing_status = "open"

    # 5. Save the listing and handle potential errors
    if @listing.save
      redirect_to dashboard_path, notice: "Your job listing was successfully posted!"
    else
      # Debugging helper to print validation errors to server log
      logger.debug "DEBUG ERROR LIST: #{@listing.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  # GET /listings/:id
  def show
    @listing = Listing.find(params[:id])
    @offers = @listing.offers.includes(:user).order(created_at: :desc)
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

  if params[:listing][:photos].is_a?(Array)
    params[:listing][:photos].reject!(&:blank?)
    params[:listing].delete(:photos) if params[:listing][:photos].empty?
  end

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

  # 4. POST /listings/:id/reopen
  def reopen
    @listing = current_user.listings.find(params[:id])
    # Setze den Status zurück auf 'open'
    if @listing.update(listing_status: 'open')
      redirect_to contractor_dashboard_path, notice: "Job listing has been reopened!"
    else
      redirect_to listing_path(@listing), alert: "Could not reopen the job."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to contractor_dashboard_path, alert: "Not authorized."
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
      :country,
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
