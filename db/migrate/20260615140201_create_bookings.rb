class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :offer, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.datetime :scheduled_date_and_time
      t.string :booking_status
      t.datetime :new_proposed_date_and_time
      t.string :proposed_by

      t.timestamps
    end
  end
end
