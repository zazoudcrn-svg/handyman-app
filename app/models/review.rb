class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :user
  belongs_to :reviewee, class_name: "User"

  validates :user_id, uniqueness: { scope: :booking_id, message: "You have already given this user a review for this job." }
end
