# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning database..."
Message.destroy_all
Review.destroy_all
Booking.destroy_all
Offer.destroy_all
DeclinedListing.destroy_all
Listing.destroy_all
Specialty.destroy_all
ContractorProfile.destroy_all
Category.destroy_all
User.destroy_all

puts "Creating trade categories..."
category_names = [
  "plumbing, heating & ac",
  "electrical & smart home",
  "woodwork & carpentry",
  "painting & drywall",
  "construction, tiling & flooring",
  "garden & outdoor",
  "locksmith & security",
  "moving & clearance",
  "cleaning services"
]

categories = {}
category_names.each do |name|
  categories[name] = Category.create!(name: name)
end

plumbing_category = categories["plumbing, heating & ac"]

# ==========================================
# THE MAIN CONTRACTOR (PLUMBER HQ)
# ==========================================
puts "Creating the Plumber Contractor..."
contractor = User.create!(
  email: "contractor@gmail.com",
  password: "password123",
  role: "contractor",
  first_name: "John",
  last_name: "Doe",
  street: "Oxford Street 100",
  postcode: "W1D 1LL",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5152,
  longitude: -0.1419
)

contractor.contractor_profile.update!(
  business_name: "London Premier Plumbers 24/7",
  travel_radius: 50
)

Specialty.create!(
  user: contractor,
  category: plumbing_category
)

# ==========================================
# SCENARIO 1: EMERGENCY (Tab 1 - On Top)
# ==========================================
puts "Creating Scenario 1: Emergency Job..."
customer_1 = User.create!(email: "c1@gmail.com", password: "password123", role: "customer", first_name: "Harry", last_name: "Smith", city: "London", latitude: 51.5135, longitude: -0.1320)

Listing.create!(
  user: customer_1,
  category: plumbing_category,
  title: "EMERGENCY: Burst pipe in kitchen, Soho restaurant area!",
  description: "A major water pipe has burst behind the commercial dishwasher in our restaurant kitchen. Water is actively leaking onto the floor. We need someone with tools to shut down the mains and replace the section of the pipe immediately before the evening shift starts.",
  street: "Dean Street 12", postcode: "W1D 3R7", city: "London", country: "United Kingdom", latitude: 51.5135, longitude: -0.1320
)

# ==========================================
# SCENARIO 2: NORMAL JOB (Tab 1 - Below Emergency)
# ==========================================
puts "Creating Scenario 2: Normal Available Job..."
customer_2 = User.create!(email: "c2@gmail.com", password: "password123", role: "customer", first_name: "Anna", last_name: "Jones", city: "Croydon", latitude: 51.3742, longitude: -0.0964)

Listing.create!(
  user: customer_2,
  category: plumbing_category,
  title: "Install new kitchen sink and mixer tap",
  description: "We recently bought a composite granite kitchen sink and a new pull-out mixer tap from IKEA. We need a professional plumber to remove the old stainless steel sink, fit the new one into the wooden worktop, and connect all the new plumbing and waste pipes underneath.",
  street: "George Street 5", postcode: "CR0 1PE", city: "Croydon", country: "United Kingdom", latitude: 51.3742, longitude: -0.0964
)

# ==========================================
# SCENARIO 3: PENDING OFFER (Tab 2) + MESSAGES
# ==========================================
puts "Creating Scenario 3: Sent Offer Pending with Chat History..."
customer_3 = User.create!(email: "c3@gmail.com", password: "password123", role: "customer", first_name: "Bob", last_name: "Miller", city: "Stratford", latitude: 51.5416, longitude: 0.0021)

listing_offer = Listing.create!(
  user: customer_3,
  category: plumbing_category,
  title: "Low water pressure and leaking bathroom boiler",
  description: "Our Combi boiler has been losing pressure rapidly over the last week. I noticed a small, constant drip coming from one of the copper pipe connections directly underneath the unit. Looking for someone to inspect the system, tighten or replace the valve, and repressurize the boiler.",
  street: "Broadway 10", postcode: "E15 4QS", city: "London", country: "United Kingdom", latitude: 51.5416, longitude: 0.0021
)

offer_pending = Offer.create!(user: contractor, listing: listing_offer, quote: 250)

Message.create!(
  offer: offer_pending,
  user: customer_3,
  content: "Hi John, thanks for the quote. Does the £250 include all the materials for the boiler valve repair?"
)

Message.create!(
  offer: offer_pending,
  user: contractor,
  content: "Hi Bob! Yes, that includes the standard replacement valves and 1 hour of labor. If we find deeper issues, I will let you know on-site."
)

Message.create!(
  offer: offer_pending,
  user: customer_3,
  content: "Sounds fair. Let me check with my landlord tonight and I'll get back to you!"
)

# ==========================================
# SCENARIO 4: BOOKING WITHOUT REVIEW (Tab 3 - Ongoing) + MESSAGES
# ==========================================
puts "Creating Scenario 4: Active Booking (No Review yet) with Chat History..."
customer_4 = User.create!(email: "c4@gmail.com", password: "password123", role: "customer", first_name: "Alice", last_name: "Green", city: "Greenwich", latitude: 51.4826, longitude: -0.0077)

listing_booking_ongoing = Listing.create!(
  user: customer_4,
  category: plumbing_category,
  title: "Replace radiator valves in commercial office",
  description: "We have 4 manual radiator valves across our office space that are seized up and cannot be adjusted. We need them replaced with modern Thermostatic Radiator Valves (TRVs) so our staff can control the temperature. The heating system will need to be partially drained to complete the installation.",
  street: "Greenwich High Rd 15", postcode: "SE10 8JA", city: "London", country: "United Kingdom", latitude: 51.4826, longitude: -0.0077
)

offer_ongoing = Offer.create!(user: contractor, listing: listing_booking_ongoing, quote: 450)

Booking.create!(
  offer: offer_ongoing,
  listing: listing_booking_ongoing,
  booking_status: "confirmed",
  scheduled_date_and_time: "2026-06-25 09:00:00"
)

Message.create!(
  offer: offer_ongoing,
  user: contractor,
  content: "Good morning Alice, I'm scheduled to replace your radiator valves on June 25th at 09:00. Where is the best place to park my van near the office?"
)

Message.create!(
  offer: offer_ongoing,
  user: customer_4,
  content: "Hi John! You can park right in our visitor loading bay at the back of the building. Just ring the buzzer and reception will let you in."
)

# ==========================================
# SCENARIO 5: BOOKING WITH REVIEW (Tab 3 - Completed)
# ==========================================
puts "Creating Scenario 5: Completed Booking with 5-Star Review..."
customer_5 = User.create!(email: "c5@gmail.com", password: "password123", role: "customer", first_name: "David", last_name: "Brown", city: "Brixton", latitude: 51.4623, longitude: -0.1149)

listing_completed = Listing.create!(
  user: customer_5,
  category: plumbing_category,
  title: "Fix leaking shower enclosure and reseal tray",
  description: "Water has started seeping through the bathroom floor into the hallway downstairs whenever someone showers. The silicone seals around the bottom of the glass enclosure look worn out. Needs old silicone stripped out, area sanitized, and a fresh bead of heavy-duty waterproof silicone applied.",
  street: "Brixton Rd 200", postcode: "SW9 6AP", city: "London", country: "United Kingdom", latitude: 51.4623, longitude: -0.1149
)

offer_completed = Offer.create!(user: contractor, listing: listing_completed, quote: 180)

booking_completed = Booking.create!(
  offer: offer_completed,
  listing: listing_completed,
  booking_status: "completed",
  scheduled_date_and_time: "2026-06-10 14:00:00"
)

Review.create!(
  booking: booking_completed,
  user: customer_5,
  reviewee: contractor,
  rating: 5,
  content: "Brilliant service, fixed the leak within an hour. Highly recommended!"
)

# ==========================================
# SCENARIO 6: DECLINED JOB (Tab 4)
# ==========================================
puts "Creating Scenario 6: Declined Job..."
customer_6 = User.create!(email: "c6@gmail.com", password: "password123", role: "customer", first_name: "Lucy", last_name: "Heart", city: "Watford", latitude: 51.6565, longitude: -0.3942)

listing_declined = Listing.create!(
  user: customer_6,
  category: plumbing_category,
  title: "Fix leaking outdoor garden tap",
  description: "Our brass outdoor garden tap has developed a constant leak from the spindle when turned on. It's wasting water in the garden. Needs a quick washer replacement or a completely new outdoor tap unit fitted to the external wall pipeline.",
  street: "High Street 45", postcode: "WD17 2DJ", city: "Watford", country: "United Kingdom", latitude: 51.6565, longitude: -0.3942
)

DeclinedListing.create!(user: contractor, listing: listing_declined)

puts "Seeds rebuilt successfully!"
