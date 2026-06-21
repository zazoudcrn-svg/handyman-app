class AddFieldsToOffers < ActiveRecord::Migration[8.1]
  def change
    add_column :offers, :estimated_duration_hours, :float
    add_column :offers, :suggested_date_and_time, :datetime
  end
end
