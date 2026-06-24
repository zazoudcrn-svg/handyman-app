class Booking < ApplicationRecord
  belongs_to :offer
  belongs_to :listing

  # Allow editing listing fields through booking form
  accepts_nested_attributes_for :listing

  has_one :contractor, through: :offer, source: :user
  has_one :customer, through: :listing, source: :user

  validates :scheduled_date_and_time, presence: true

  enum :booking_status, {
    pending: "pending",
    confirmed: "confirmed",
    date_change_requested: "date_change_requested",
    completed: "completed",
    cancelled: "cancelled"
  }

  # --- Callbacks ---
  after_update :notify_booking_status_change

  def proposed?
    new_proposed_date_and_time.present?
  end

  def proposed_by_customer?
    proposed_by == "customer"
  end

  def proposed_by_contractor?
    proposed_by == "contractor"
  end

  private

  def notify_booking_status_change
    if saved_change_to_booking_status?
      case booking_status
      when "confirmed"
        NotificationJob.perform_later("booking_confirmed", contractor, self)
        NotificationJob.perform_later("booking_confirmed", customer, self)
      when "cancelled"
        NotificationJob.perform_later("booking_cancelled", contractor, self)
        NotificationJob.perform_later("booking_cancelled", customer, self)
      end
    end

    if saved_change_to_scheduled_date_and_time?
      NotificationJob.perform_later("date_changed", contractor, self)
      NotificationJob.perform_later("date_changed", customer, self)
    end
  end
end
