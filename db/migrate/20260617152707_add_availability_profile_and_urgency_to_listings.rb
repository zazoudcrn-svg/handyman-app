class AddAvailabilityProfileAndUrgencyToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :availability_profile, :string
    add_column :listings, :urgency, :string
    add_column :listings, :ai_answers, :json
  end
end
