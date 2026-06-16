class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :preferred_date_and_time
      t.string :listing_status
      t.string :street
      t.string :city
      t.string :postcode
      t.string :country

      t.timestamps
    end
  end
end
