class AddCancellationFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :cancellation_note, :text
    add_column :bookings, :cancelled_by, :string
  end
end
