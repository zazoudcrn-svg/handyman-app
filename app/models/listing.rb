class Listing < ApplicationRecord
  attr_accessor :issue_duration, :attempted_fix, :material_preferences, :custom_availability
  belongs_to :user
  belongs_to :category
  has_many :offers
  has_one :booking
  has_many_attached :photos
end
