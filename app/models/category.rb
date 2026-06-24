class Category < ApplicationRecord
  has_many :listings # ← ADD THIS
  has_many :specialties
  has_many :users, through: :specialties
end
