class Listing < ApplicationRecord
  attr_accessor :issue_duration, :attempted_fix, :material_preferences, :custom_availability
  belongs_to :user
  belongs_to :category
  has_many :offers
  has_one :booking
  has_many_attached :photos

  # --- Geocoding Setup ---
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){ obj.street_changed? || obj.postcode_changed? || obj.city_changed? }

  def full_address
    [street, postcode, city, country].compact.join(', ')
  end
end
