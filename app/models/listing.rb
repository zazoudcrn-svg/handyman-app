class Listing < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :offers
  has_one :booking
end
