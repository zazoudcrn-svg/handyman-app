class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.references :user, null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.float :quote
      t.text :note
      t.string :offer_status

      t.timestamps
    end
  end
end
