# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# ==============================================================================
# DATABASE RESET & CLEANUP
# ==============================================================================
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

# ==============================================================================
# CATEGORIES CREATION
# ==============================================================================
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

# ==============================================================================
# THE MAIN CONTRACTOR PROFILE (LONDON PREMIER PLUMBERS)
# ==============================================================================
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

# ==============================================================================
# MASTER DEMO CUSTOMER (DAVID BROWN) - Defined early to reuse IDs safely
# ==============================================================================
puts "Creating Master Demo Customer (David Brown)..."
customer_5 = User.create!(
  email: "c5@gmail.com",
  password: "password123",
  role: "customer",
  first_name: "David",
  last_name: "Brown",
  city: "Brixton",
  country: "United Kingdom",
  latitude: 51.4623,
  longitude: -0.1149
)

# ==============================================================================
# SCENARIO 1: EMERGENCY JOB (Tab 1 - Appears on very top via SQL order)
# ==============================================================================
puts "Creating Scenario 1: Emergency Job..."
customer_1 = User.create!(email: "c1@gmail.com", password: "password123", role: "customer", first_name: "Harry", last_name: "Smith", city: "London", latitude: 51.5135, longitude: -0.1320)

Listing.create!(
  user: customer_1,
  category: plumbing_category,
  title: "EMERGENCY: Burst pipe in kitchen, Soho restaurant area!",
  description: "A major water pipe has burst behind the commercial dishwasher in our restaurant kitchen. Water is actively leaking onto the floor. We need someone with tools to shut down the mains and replace the section of the pipe immediately before the evening shift starts.",
  street: "Dean Street 12", postcode: "W1D 3R7", city: "London", country: "United Kingdom", latitude: 51.5135, longitude: -0.1320, urgency: "normal", availability_profile: "anytime"
)

# ==============================================================================
# SCENARIO 2: NORMAL JOB (Tab 1 - Connected to David Brown for Open Requests)
# ==============================================================================
puts "Creating Scenario 2: Normal Available Job..."
Listing.create!(
  user: customer_5,
  category: plumbing_category,
  title: "Install new kitchen sink and mixer tap",
  description: "We recently bought a composite granite kitchen sink and a new pull-out mixer tap from IKEA. We need a professional plumber to remove the old stainless steel sink, fit the new one into the wooden worktop, and connect all the new plumbing and waste pipes underneath.",
  street: "George Street 5", postcode: "CR0 1PE", city: "Croydon", country: "United Kingdom", latitude: 51.3742, longitude: -0.0964, urgency: "normal", availability_profile: "anytime"
)

# ==============================================================================
# SCENARIO 3: PENDING OFFER WITH CONVERSATION HISTORY (Tab 2 - Connected to David Brown)
# ==============================================================================
puts "Creating Scenario 3: Sent Offer Pending with Chat History..."
listing_offer = Listing.create!(
  user: customer_5,
  category: plumbing_category,
  title: "Low water pressure and leaking bathroom boiler",
  description: "Our Combi boiler has been losing pressure rapidly over the last week. I noticed a small, constant drip coming from one of the copper pipe connections directly underneath the unit. Looking for someone to inspect the system, tighten or replace the valve, and repressurize the boiler.",
  street: "Broadway 10", postcode: "E15 4QS", city: "London", country: "United Kingdom", latitude: 51.5416, longitude: 0.0021, urgency: "normal", availability_profile: "anytime"
)

offer_pending = Offer.create!(
  user: contractor,
  listing: listing_offer,
  quote: 250,
  note: "I can come over on Friday morning to inspect the combi boiler, tighten the copper connections, and run a pressure test. The price includes standard replacement seals and minor valves.",
  suggested_date_and_time: "2026-06-26 10:00:00",
  estimated_duration_hours: 2.0
)

Message.create!(
  offer: offer_pending,
  user: customer_5,
  content: "Hi John, thanks for the quote. Does the £250 include all the materials for the boiler valve repair?"
)

Message.create!(
  offer: offer_pending,
  user: contractor,
  content: "Hi David! Yes, that includes the standard replacement valves and 1 hour of labor. If we find deeper issues, I will let you know on-site."
)

Message.create!(
  offer: offer_pending,
  user: customer_5,
  content: "Sounds fair. Let me check with my landlord tonight and I'll get back to you!"
)

# ==============================================================================
# SCENARIO 4: ACTIVE BOOKINGS FOR CALENDAR VIEW DENSITY (Tab 3 - Connected to David Brown)
# ==============================================================================
puts "Creating Scenario 4: Ongoing Bookings and Schedule Patterns..."

# Booking 1: Morning slot on Thursday (David's active booking)
listing_booking_ongoing = Listing.create!(
  user: customer_5, category: plumbing_category,
  title: "Replace radiator valves in commercial office",
  description: "We have 4 manual radiator valves across our office space that are seized up and cannot be adjusted. We need them replaced with modern Thermostatic Radiator Valves (TRVs).",
  street: "Greenwich High Rd 15", postcode: "SE10 8JA", city: "London", country: "United Kingdom", latitude: 51.4826, longitude: -0.0077, urgency: "normal", availability_profile: "anytime"
)
offer_ongoing = Offer.create!(
  user: contractor, listing: listing_booking_ongoing, quote: 450,
  note: "Quote includes 4 high-quality Thermostatic Radiator Valves (TRVs) and draining down the commercial heating system loop. Fully certified for office installations.",
  suggested_date_and_time: "2026-06-25 09:00:00", estimated_duration_hours: 3.5
)
Booking.create!(offer: offer_ongoing, listing: listing_booking_ongoing, booking_status: "confirmed", scheduled_date_and_time: "2026-06-25 09:00:00")
Message.create!(offer: offer_ongoing, user: contractor, content: "Good morning David, I'm scheduled to replace your radiator valves on June 25th at 09:00. Where is the best place to park my van near the office?")

# Booking 2: Afternoon slot on the same Thursday (Density filler)
customer_extra_1 = User.create!(email: "ce1@gmail.com", password: "password123", role: "customer", first_name: "Tom", last_name: "Baker", city: "London", latitude: 51.5110, longitude: -0.1420)
listing_extra_1 = Listing.create!(user: customer_extra_1, category: plumbing_category, title: "Emergency drain unblocking and cleanup", description: "Kitchen drain is overflowing and needs urgent hydro-jetting to clear blockage.", street: "Piccadilly 50", postcode: "W1J 0DX", city: "London", country: "United Kingdom", latitude: 51.5110, longitude: -0.1420, urgency: "normal", availability_profile: "anytime")
offer_extra_1 = Offer.create!(
  user: contractor, listing: listing_extra_1, quote: 320,
  note: "Urgent response slot booked. Bringing industrial hydro-jetting equipment to clear out the blocked pipe system.",
  suggested_date_and_time: "2026-06-25 14:30:00", estimated_duration_hours: 2.0
)
Booking.create!(offer: offer_extra_1, listing: listing_extra_1, booking_status: "confirmed", scheduled_date_and_time: "2026-06-25 14:30:00")

# Booking 3: Midday slot on Wednesday (Density filler)
customer_extra_2 = User.create!(email: "ce2@gmail.com", password: "password123", role: "customer", first_name: "Sarah", last_name: "Connor", city: "London", latitude: 51.5120, longitude: -0.1430)
listing_extra_2 = Listing.create!(user: customer_extra_2, category: plumbing_category, title: "Annual safety check and power flush", description: "Full heating system inspection and power flush to remove sludge and improve efficiency.", street: "Regent Street 20",  postcode: "W1B 5AH", city: "London", country: "United Kingdom", latitude: 51.5120, longitude: -0.1430, urgency: "normal", availability_profile: "anytime")
offer_extra_2 = Offer.create!(
  user: contractor, listing: listing_extra_2, quote: 580,
  note: "Comprehensive central heating service including full system power flush with protective chemicals to clean sludge from radiators.",
  suggested_date_and_time: "2026-06-24 11:00:00", estimated_duration_hours: 4.0
)
Booking.create!(offer: offer_extra_2, listing: listing_extra_2, booking_status: "confirmed", scheduled_date_and_time: "2026-06-24 11:00:00")

# ==============================================================================
# SCENARIO 5: ARCHIVED COMPLETED PROJECTS WITH REVIEWS (Tab 4)
# ==============================================================================
puts "Creating Scenario 5: Multiple Completed Bookings with Two-Way Ratings..."

# Historical Job 1: Two-Way Review (David's completed job)
listing_completed_1 = Listing.create!(
  user: customer_5, category: plumbing_category,
  title: "Fix leaking shower enclosure and reseal tray",
  description: "Water has started seeping through the bathroom floor into the hallway downstairs whenever someone showers. Needs old silicone stripped out, area sanitized, and a fresh bead applied.",
  street: "Brixton Rd 200", postcode: "SW9 6AP", city: "London", country: "United Kingdom", latitude: 51.4623, longitude: -0.1149, urgency: "normal", availability_profile: "anytime"
)
offer_completed_1 = Offer.create!(
  user: contractor, listing: listing_completed_1, quote: 180,
  note: "Will remove all degraded silicone sealants, apply professional anti-mould sanitary sealant, and check the drain alignment underneath.",
  suggested_date_and_time: "2026-06-10 14:00:00", estimated_duration_hours: 1.5
)
booking_completed_1 = Booking.create!(offer: offer_completed_1, listing: listing_completed_1, booking_status: "completed", scheduled_date_and_time: "2026-06-10 14:00:00")

# 1a. Customer reviews Contractor
Review.create!(booking: booking_completed_1, user: customer_5, reviewee: contractor, rating: 5, content: "Brilliant service, fixed the leak within an hour. Highly recommended!")
# 1b. Contractor reviews Customer
Review.create!(booking: booking_completed_1, user: contractor, reviewee: customer_5, rating: 5, content: "David was very welcoming, clearly explained the issue, and paid immediately. Great customer!")

# Historical Job 2: Two-Way Review
customer_history_1 = User.create!(email: "ch1@gmail.com", password: "password123", role: "customer", first_name: "Michael", last_name: "Caine", city: "Chelsea", latitude: 51.4875, longitude: -0.1682)
listing_completed_2 = Listing.create!(
  user: customer_history_1, category: plumbing_category,
  title: "Blocked toilet drainage and pipe inspection",
  description: "Main bathroom toilet is completely blocked and backing up. Tried plunging but didn't help. Need professional drainage clearance equipment.",
  street: "Baker Street 221B",
  postcode: "NW1 6XE",
  city: "London",
  country: "United Kingdom",
  urgency: "normal",
  availability_profile: "anytime"
)
offer_completed_2 = Offer.create!(
  user: contractor, listing: listing_completed_2, quote: 120,
  note: "Standard fixed price drainage clearance call-out including high-power auger tool usage.",
  suggested_date_and_time: "2026-05-28 09:30:00", estimated_duration_hours: 1.0
)
booking_completed_2 = Booking.create!(offer: offer_completed_2, listing: listing_completed_2, booking_status: "completed", scheduled_date_and_time: "2026-05-28 09:30:00")

# 2a. Customer reviews Contractor
Review.create!(booking: booking_completed_2, user: customer_history_1, reviewee: contractor, rating: 5, content: "Very fast response time. Cleared the blockage in no time and gave useful maintenance tips.")
# 2b. Contractor reviews Customer
Review.create!(booking: booking_completed_2, user: contractor, reviewee: customer_history_1, rating: 5, content: "Access to the bathroom was cleared before I arrived. Smooth communication, highly recommended property owner.")

# Historical Job 3: Two-Way Review
customer_history_2 = User.create!(email: "ch2@gmail.com", password: "password123", role: "customer", first_name: "Emma", last_name: "Watson", city: "Camden", latitude: 51.5364, longitude: -0.1412)
listing_completed_3 = Listing.create!(
  user: customer_history_2, category: plumbing_category,
  title: "Fit new designer vertical radiator in hallway",
  description: "Need an old standard radiator swapped out for a new anthracite vertical designer radiator. Pipes will need slight modification to fit the new layout.",
 street: "Camden High Street 12",
  postcode: "NW1 7JE",
  city: "London",
  country: "United Kingdom",
  urgency: "normal",
  availability_profile: "anytime"
  )
offer_completed_3 = Offer.create!(
  user: contractor, listing: listing_completed_3, quote: 380,
  note: "Includes mounting the new designer radiator bracket on brick wall, aligning the copper pipe work, and testing the system loop for leaks.",
  suggested_date_and_time: "2026-05-14 11:00:00", estimated_duration_hours: 3.0
)
booking_completed_3 = Booking.create!(offer: offer_completed_3, listing: listing_completed_3, booking_status: "completed", scheduled_date_and_time: "2026-05-14 11:00:00")

# 3a. Customer reviews Contractor
Review.create!(booking: booking_completed_3, user: customer_history_2, reviewee: contractor, rating: 4, content: "Great craftsmanship, tidy worker. The custom radiator pipe modification looks very neat. Took slightly longer than expected but happy with the result.")
# 3b. Contractor reviews Customer
Review.create!(booking: booking_completed_3, user: contractor, reviewee: customer_history_2, rating: 4, content: "Nice job to work on. Hallway was a bit crowded with boxes which delayed the pipe layout setup slightly, but Emma was super friendly and offered coffee!")

# ==============================================================================
# SCENARIO 6: DECLINED LISTINGS (Tab 6)
# ==============================================================================
puts "Creating Scenario 6: Declined Job..."
customer_6 = User.create!(email: "c6@gmail.com", password: "password123", role: "customer", first_name: "Lucy", last_name: "Heart", city: "Watford", latitude: 51.6565, longitude: -0.3942)

listing_declined = Listing.create!(
  user: customer_6,
  category: plumbing_category,
  title: "Fix leaking outdoor garden tap",
  description: "Our brass outdoor garden tap has been leaking constantly from the spindle when turned on. It's wasting water in the garden.",
  street: "High Street 45", postcode: "WD17 2DJ", city: "Watford", country: "United Kingdom", latitude: 51.6565, longitude: -0.3942, urgency: "normal", availability_profile: "anytime"
)

DeclinedListing.create!(user: contractor, listing: listing_declined)
# ==============================================================================
# SCENARIO 7: Full Customer Journey (Pending, Declined, Proposed Date, Confirmed,
# Completed, Customer-Cancelled, Contractor-Cancelled)
# ==============================================================================

puts "Creating Scenario 7: Full Customer Journey..."

customer_7 = User.create!(
  email: "c7@gmail.com",
  password: "password123",
  role: "customer",
  first_name: "Oliver",
  last_name: "Grant",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5090,
  longitude: -0.1337
)

# 1. PENDING BOOKING
listing_pending = Listing.create!(
  user: customer_7,
  category: plumbing_category,
  title: "Kitchen tap dripping and needs replacement",
  description: "Our kitchen mixer tap has been dripping for weeks. We bought a new tap from B&Q and need it installed.",
  street: "Charlotte Street 21",
  postcode: "W1T 1RJ",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5200,
  longitude: -0.1350,
  urgency: "normal",
  availability_profile: "anytime"
)

offer_pending = Offer.create!(
  user: contractor,
  listing: listing_pending,
  quote: 95,
  note: "Includes removing the old tap, installing the new one, and checking for leaks.",
  suggested_date_and_time: "2026-07-04 11:00:00",
  estimated_duration_hours: 1.0
)

Booking.create!(
  offer: offer_pending,
  listing: listing_pending,
  booking_status: "pending",
  scheduled_date_and_time: "2026-07-04 11:00:00"
)

# 2. DECLINED LISTING
listing_declined = Listing.create!(
  user: customer_7,
  category: plumbing_category,
  title: "Replace old toilet flush mechanism",
  description: "The toilet flush handle is loose and the internal mechanism is worn out. Needs replacement.",
  street: "Trafalgar Square 3",
  postcode: "WC2N 5DN",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5080,
  longitude: -0.1281,
  urgency: "normal",
  availability_profile: "anytime"
)

DeclinedListing.create!(
  user: contractor,
  listing: listing_declined
)

# 3. PROPOSED NEW DATE
listing_proposed = Listing.create!(
  user: customer_7,
  category: plumbing_category,
  title: "Shower pressure extremely low",
  description: "The shower pressure has dropped significantly. Might be a clogged filter or faulty pump.",
  street: "Leicester Square 18",
  postcode: "WC2H 7NA",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5100,
  longitude: -0.1300,
  urgency: "normal",
  availability_profile: "anytime"
)

offer_proposed = Offer.create!(
  user: contractor,
  listing: listing_proposed,
  quote: 160,
  note: "Will inspect the pump, clean filters, and test the pressure.",
  suggested_date_and_time: "2026-07-06 15:00:00",
  estimated_duration_hours: 1.5
)

Booking.create!(
  offer: offer_proposed,
  listing: listing_proposed,
  booking_status: "pending",
  new_proposed_date_and_time: "2026-07-07 10:00:00",
  proposed_by: "customer",   # or "contractor"
  scheduled_date_and_time: "2026-07-06 15:00:00"
)

# 4. CONFIRMED BOOKING
listing_confirmed = Listing.create!(
  user: customer_7,
  category: plumbing_category,
  title: "Install new under-sink water filter system",
  description: "We bought a 3-stage water filtration system from Amazon and need a plumber to install it.",
  street: "Wardour Street 88",
  postcode: "W1F 0TN",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5130,
  longitude: -0.1350,
  urgency: "normal",
  availability_profile: "anytime"
)

offer_confirmed = Offer.create!(
  user: contractor,
  listing: listing_confirmed,
  quote: 140,
  note: "Includes drilling the countertop for the tap, connecting the filter system, and testing for leaks.",
  suggested_date_and_time: "2026-07-03 10:00:00",
  estimated_duration_hours: 1.5
)

Booking.create!(
  offer: offer_confirmed,
  listing: listing_confirmed,
  booking_status: "confirmed",
  scheduled_date_and_time: "2026-07-03 10:00:00"
)

# 5. COMPLETED BOOKING
listing_completed = Listing.create!(
  user: customer_7,
  category: plumbing_category,
  title: "Repair leaking bathtub waste pipe",
  description: "Water is dripping through the ceiling below the bathroom whenever the bathtub drains.",
  street: "Berwick Street 42",
  postcode: "W1F 8RX",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5138,
  longitude: -0.1365,
  urgency: "normal",
  availability_profile: "anytime"
)

offer_completed = Offer.create!(
  user: contractor,
  listing: listing_completed,
  quote: 180,
  note: "Will remove the bath panel, inspect the waste trap, replace seals, and test drainage.",
  suggested_date_and_time: "2026-06-18 14:00:00",
  estimated_duration_hours: 2.0
)

Booking.create!(
  offer: offer_completed,
  listing: listing_completed,
  booking_status: "completed",
  scheduled_date_and_time: "2026-06-18 14:00:00"
)

# 6. CUSTOMER-CANCELLED BOOKING
listing_customer_cancel = Listing.create!(
  user: customer_7,
  category: plumbing_category,
  title: "Fix leaking washing machine hose",
  description: "Water is leaking from the back of the washing machine. Likely a loose or cracked hose.",
  street: "Soho Square 7",
  postcode: "W1D 3QB",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5150,
  longitude: -0.1320,
  urgency: "normal",
  availability_profile: "anytime"
)

offer_customer_cancel = Offer.create!(
  user: contractor,
  listing: listing_customer_cancel,
  quote: 110,
  note: "Will inspect the hose, replace if needed, and test the machine.",
  suggested_date_and_time: "2026-07-08 12:00:00",
  estimated_duration_hours: 1.0
)

Booking.create!(
  offer: offer_customer_cancel,
  listing: listing_customer_cancel,
  booking_status: "cancelled",
  cancellation_note: "Customer cancelled due to emergency travel",
  scheduled_date_and_time: "2026-07-08 12:00:00"
)

# 7. CONTRACTOR-CANCELLED BOOKING
listing_contractor_cancel = Listing.create!(
  user: customer_7,
  category: plumbing_category,
  title: "Unblock slow draining kitchen sink",
  description: "The kitchen sink drains very slowly. Tried using drain cleaner but no improvement.",
  street: "Soho Square 7",
  postcode: "W1D 3QB",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5150,
  longitude: -0.1320,
  urgency: "normal",
  availability_profile: "anytime"
)

offer_contractor_cancel = Offer.create!(
  user: contractor,
  listing: listing_contractor_cancel,
  quote: 90,
  note: "Will use a manual auger and check the U-bend for blockages.",
  suggested_date_and_time: "2026-07-09 09:00:00",
  estimated_duration_hours: 1.0
)

Booking.create!(
  offer: offer_contractor_cancel,
  listing: listing_contractor_cancel,
  booking_status: "cancelled",
  cancellation_note: "Contractor cancelled due to overbooked schedule",
  scheduled_date_and_time: "2026-07-09 09:00:00"
)

# ==============================================================================
# SEED TERMINATION FEEDBACK
# ==============================================================================
puts "Seeds rebuilt successfully!"
