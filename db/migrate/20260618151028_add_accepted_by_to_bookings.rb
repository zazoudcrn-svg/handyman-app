class AddAcceptedByToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :accepted_by, :string
  end
end
