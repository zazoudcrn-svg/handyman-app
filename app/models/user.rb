class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :contractor_profile
  accepts_nested_attributes_for :contractor_profile
  has_many :specialties
  has_many :categories, through: :specialties
  # Ensure all associated listings are deleted when the user account is destroyed
  has_many :listings, dependent: :destroy
  has_many :offers
  has_many :messages
  has_many :bookings, through: :offers
  has_many :reviews_given, class_name: "Review", foreign_key: "user_id"
  has_many :reviews_received, class_name: "Review", foreign_key: "reviewee_id"
  has_many :declined_listings, dependent: :destroy

  # --- Geocoding Setup ---
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj){ obj.street_changed? || obj.postcode_changed? || obj.city_changed? }

  # Automatically trigger profile creation right after a new user is saved
  after_create :create_contractor_profile_if_needed

  def full_address
    [street, postcode, city, country].compact.join(', ')
  end

  def customer?
    role == "customer"
  end

  def contractor?
    role == "contractor"
  end

  private

  # Check the database 'role' column and build a contractor profile if matched
  def create_contractor_profile_if_needed
    if role.to_s == "contractor"
      create_contractor_profile!
    end
  end
end
