class Offer < ApplicationRecord
  belongs_to :user
  belongs_to :listing
  has_many :messages
  has_one :booking
end
