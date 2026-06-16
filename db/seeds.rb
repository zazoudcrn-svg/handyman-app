# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Message.destroy_all
Review.destroy_all
Booking.destroy_all
Offer.destroy_all
Listing.destroy_all
Specialty.destroy_all
ContractorProfile.destroy_all
Category.destroy_all
User.destroy_all

user = User.create!(
  email: "test@gmail.com",
  password: "password123",
  role: "contractor",
  first_name: "John",
  last_name: "Doe"
  )

ContractorProfile.create!(
  user: user,
  business_name: "Fun Painters"
  )

category = Category.create!(
  name: "Painting"
  )

Specialty.create!(
  user: user,
  category: category
  )

listing = Listing.create!(
  user: user,
  category: category,
  title: "Paint my living room"
  )

offer = Offer.create!(
  user: user,
  listing: listing,
  quote: 150
  )

booking = Booking.create!(
  offer: offer,
  listing: listing,
  booking_status: "confirmed"
  )

Review.create!(
  booking: booking,
  user: user,
  rating: 5
  )

Message.create!(
  offer: offer,
  user: user,
  content: "That quote is too high"
  )
