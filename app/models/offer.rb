class Offer < ApplicationRecord
  belongs_to :user
  belongs_to :listing
  has_many :messages
  has_one :booking

  # --- Callbacks ---
  after_create :notify_new_offer
  after_update :notify_offer_updated, if: :relevant_changes?

  private

  def notify_new_offer
    customer = listing.user
    NotificationJob.perform_later("new_offer", customer, self)
  end

  def notify_offer_updated
    customer = listing.user
    NotificationJob.perform_later("offer_updated", customer, self)
  end

  def relevant_changes?
    saved_change_to_quote? || saved_change_to_suggested_date_and_time? || saved_change_to_note?
  end
end
