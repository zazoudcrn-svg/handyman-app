class AddOnboardingSkippedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :onboarding_skipped, :boolean, default: false
  end
end
