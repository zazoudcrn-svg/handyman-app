# frozen_string_literal: true

# Custom Devise RegistrationsController to handle specialized onboarding routing and cookie checks
class Users::RegistrationsController < Devise::RegistrationsController
  # Intercept the sign-up view request to check for existing account cookies
  before_action :redirect_if_account_exists, only: [:new]

  protected

  # Overriding Devise's internal resource builder method.
  # This executes right before the user record is validated and saved to the database.
  def build_resource(hash = {})
    super
    # Manually extract the top-level :role parameter from the form submission (hidden_field_tag)
    # and assign it directly to the user instance before database persistence.
    self.resource.role = params[:role] if params[:role].present?
  end

  private

  # Prevents infinite redirect loops by inspecting tracking cookies
  def redirect_if_account_exists
    # If the explicit bypass parameter is provided, clear the tracking cookie to allow a new registration
    if params[:bypass_cookie] == "true"
      cookies.delete(:has_account)
      return
    end

    # If the user tracking cookie indicates an active account state,
    # forward them to the sign-in screen while safely preserving their intended role.
    if cookies[:has_account] == "true"
      redirect_to new_user_session_path(role: params[:role]), alert: "Welcome back! Please log in to your account."
    end
  end
end
