class Offer < ApplicationRecord
  belongs_to :user
  belongs_to :listing
  has_many :messages
  has_one :booking

  # --- Callbacks ---
  after_create :notify_new_offer
  after_update :notify_offer_updated

  private

  def notify_new_offer
    customer = listing.user
    NotificationJob.perform_later("new_offer", customer, self)
  end

  def notify_offer_updated
    customer = listing.user
    NotificationJob.perform_later("offer_updated", customer, self)
  end
end
