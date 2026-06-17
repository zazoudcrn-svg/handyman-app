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

contractor = User.create!(
  email: "contractor@gmail.com",
  password: "password123",
  role: "contractor",
  first_name: "John",
  last_name: "Doe"
  )

ContractorProfile.create!(
  user: contractor,
  business_name: "Fun Painters"
  )

customer = User.create!(
  email: "customer@gmail.com",
  password: "password1234",
  role: "customer",
  first_name: "Harry",
  last_name: "Smith"
  )

category = Category.create!(
  name: "Painting"
  )

Specialty.create!(
  user: contractor,
  category: category
  )

listing = Listing.create!(
  user: customer,
  category: category,
  title: "Paint my living room"
  )

offer = Offer.create!(
  user: contractor,
  listing: listing,
  quote: 150
  )

booking = Booking.create!(
  offer: offer,
  listing: listing,
  booking_status: "confirmed",
  scheduled_date_and_time: "2026-06-12 15:35:00"
  )

Review.create!(
  booking: booking,
  user: customer,
  reviewee: contractor,
  rating: 5
  )

Message.create!(
  offer: offer,
  user: customer,
  content: "That quote is too high"
  )
