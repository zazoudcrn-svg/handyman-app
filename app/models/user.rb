class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :contractor_profile
  has_many :specialties
  has_many :categories, through: :specialties
  has_many :listings
  has_many :offers
  has_many :messages
  has_many :bookings, through: :offers
  has_many :reviews_given, class_name: "Review", foreign_key: "user_id"
  has_many :reviews_received, class_name: "Review", foreign_key: "reviewee_id"
end
