class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :user
  belongs_to :reviewee, class_name: "User"

  validates :user_id, uniqueness: { scope: :booking_id, message: "You have already given this user a review for this job." }

  # --- Callbacks ---
  after_create :notify_new_review

  private

  def notify_new_review
    NotificationJob.perform_later("new_review", reviewee, self)
  end
end
