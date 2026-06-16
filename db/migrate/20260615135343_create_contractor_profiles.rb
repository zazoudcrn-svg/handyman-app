class CreateContractorProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :contractor_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.string :google_business_profile
      t.integer :travel_radius
      t.string :street
      t.string :city
      t.string :postcode
      t.string :country
      t.string :weekday_availability
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
