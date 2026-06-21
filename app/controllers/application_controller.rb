class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :authenticate_user!

  # Permit custom fields during Devise authentication processes
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Overwriting the Devise redirect path after a successful sign-in
  def after_sign_in_path_for(resource)
    # Check if the user has already completed their onboarding profile.
    # We look if a core onboarding field (like 'city' or 'postcode') is present.
    if resource.city.present?
      # If they are fully onboarded, bypass onboarding and send them straight to the dashboard
      dashboard_path
    else
      # If they haven't finished onboarding yet, route them based on their initial signup role
      if resource.role == "contractor"
        onboarding_contractor_path
      else
        onboarding_customer_path
      end
    end
  end

  # Allow Devise to accept the :role parameter from the registration smart-buttons flow
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :role ])
  end
end
