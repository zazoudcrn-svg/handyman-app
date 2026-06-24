class Message < ApplicationRecord
  belongs_to :offer
  belongs_to :user

  # --- Callbacks ---
  after_create :notify_new_message

  private

  def notify_new_message
    recipient = user == offer.user ? offer.listing.user : offer.user
    NotificationJob.perform_later("new_message", recipient, self)
  end
end
