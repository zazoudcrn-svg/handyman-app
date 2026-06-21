class CreateDeclinedListings < ActiveRecord::Migration[8.1]
  def change
    create_table :declined_listings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true

      t.timestamps
    end
  end
end
