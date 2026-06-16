class ListingsController < ApplicationController
  def new
    @listings = Listings.all
  end

  def create
    @listings = Listings.all(listing_params)
    @listing.user = current_user

    if listing.save
      redirect_to dashboard_path, notice: "Your job listing was successfully posted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

private

  def listing_params
    params.require(:listing).permit(:title, :description)
  end
end
