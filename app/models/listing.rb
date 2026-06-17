class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :offers
  has_one :booking
  has_many_attached :photos
end
