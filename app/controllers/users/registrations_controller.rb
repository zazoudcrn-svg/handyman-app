# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # Execute our custom check before loading the signup form
  before_action :redirect_if_account_exists, only: [:new]

  private

  def redirect_if_account_exists
    # 1. If the user explicitly clicked the "Sign up here" link, they want to bypass.
    # We delete the cookie immediately so they can navigate freely.
    if params[:bypass_cookie] == "true"
      cookies.delete(:has_account)
      return
    end

    # 2. Otherwise, standard redirection behavior for existing accounts
    if cookies[:has_account] == "true"
      redirect_to new_user_session_path, alert: "Welcome back! Please log in to your account."
    end
  end
end
