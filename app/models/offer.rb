class Offer < ApplicationRecord
<<<<<<< HEAD
  belongs_to :listing
  belongs_to :user
=======
  belongs_to :user
  belongs_to :listing
  has_many :messages
  has_one :booking
>>>>>>> master
end
