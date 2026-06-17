class AddRevieweeToReviews < ActiveRecord::Migration[8.1]
  def change
    add_reference :reviews, :reviewee, null: true, foreign_key: { to_table: :users }
  end
end
