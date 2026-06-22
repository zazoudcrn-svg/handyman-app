class Listing < ApplicationRecord
  # --- Virtual Attributes (Form Helpers) ---
  attr_accessor :issue_duration, :attempted_fix, :material_preferences, :custom_availability

  # --- Associations ---
  belongs_to :user
  belongs_to :category
  has_many :offers
  has_one :booking
  has_many_attached :photos # Left out of validation to remain optional
  has_many :declined_listings, dependent: :destroy

  # --- Geocoding Setup ---
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){ obj.street_changed? || obj.postcode_changed? || obj.city_changed? }

  # --- Validations ---
  # Core data integrity validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }

  # Structural selection updates
  validates :urgency, presence: true
  validates :availability_profile, presence: true


  # Address attributes required for successful geocoding execution
  validates :street, presence: true
  validates :postcode, presence: true
  validates :city, presence: true
  validates :country, presence: true

  # --- Instance Methods ---
  def full_address
    [street, postcode, city, country].compact.join(', ')
  end
end
