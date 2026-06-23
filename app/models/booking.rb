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

  def proposed?
    new_proposed_date_and_time.present?
  end

  def proposed_by_customer?
    proposed_by == "customer"
  end

  def proposed_by_contractor?
    proposed_by == "contractor"
  end
end
