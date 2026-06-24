class Listing < ApplicationRecord
  # --- Virtual Attributes (Form Helpers) ---
  attr_accessor :issue_duration, :attempted_fix, :material_preferences, :custom_availability

  # --- Associations ---
  belongs_to :user
  belongs_to :category
  has_many :offers, dependent: :destroy
  has_one :booking
  has_many_attached :photos # Left out of validation to remain optional
  validate :max_five_photos
  has_many :declined_listings, dependent: :destroy

  # --- Geocoding Setup ---
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){ obj.street_changed? || obj.postcode_changed? || obj.city_changed? }


  # --- Callbacks ---
  after_create :notify_matching_contractors
  before_destroy :cleanup_notifications


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

  private

  def cleanup_notifications
    Notification.where(resource_type: "Listing", resource_id: id).destroy_all
  end

  def notify_matching_contractors
    return unless latitude.present? && longitude.present?

    matching_contractors = User.joins(:specialties)
                               .where(specialties: { category_id: category_id })
                               .where.not(id: user_id)
                               .select { |u| u.latitude.present? && u.longitude.present? }
                               .select { |u|
                                 radius = u.contractor_profile&.travel_radius || 50
                                 Geocoder::Calculations.distance_between(
                                   [latitude, longitude],
                                   [u.latitude, u.longitude],
                                   units: :km
                                 ) <= radius
                               }

    matching_contractors.each do |contractor|
      NotificationJob.perform_later("new_match", contractor, self)
    end
  end

  def max_five_photos
    if photos.count > 5
      errors.add(:photos, "You can only upload a maximum of 5 photos")
    end
  end
end
