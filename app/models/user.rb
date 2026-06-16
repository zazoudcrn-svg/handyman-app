class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :contractor_profile
  has_many :specialties
  has_many :categories, through: :specialties
  # Ensure all associated listings are deleted when the user account is destroyed
  has_many :listings, dependent: :destroy
  has_many :offers
  has_many :reviews
  has_many :messages
  has_many :bookings, through: :offers
  has_many :reviews, through: :bookings, as: :received_reviews

  # Automatically trigger profile creation right after a new user is saved
  after_create :create_contractor_profile_if_needed

  private

  # Check the database 'role' column and build a contractor profile if matched
  def create_contractor_profile_if_needed
    if role.to_s == "contractor"
      create_contractor_profile!
    end
  end
end
