require 'open-uri'

# ==============================================================================
# PHOTO PLACEHOLDERS
# ==============================================================================
LISTING_PHOTOS = {
  tap_leak:             ["https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405092/IMG_2528_yty5fw.jpg", "https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405094/IMG_2539_zurtrm.jpg"],
  boiler:               ["https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405093/IMG_2533_sjcanf.jpg", "https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405093/IMG_2532_rij8sc.jpg"],
  switches:             ["https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405095/IMG_2535_yqjcrg.jpg", "https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405094/IMG_2534_tgitiz.jpg"],
  doors:                ["https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405095/IMG_2536_l2qlpe.jpg", "https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405094/IMG_2537_t2zfh9.jpg"],
  completed_electrical: ["https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405575/IMG_2542_xwxsie.jpg"],
  upcoming_dimmers:     ["https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405575/IMG_2540_xy2g9v.jpg", "https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782405575/IMG_2541_llxjlm.jpg"]
}

AVATAR_PHOTOS = {
  james:  "https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782409667/ben-den-engelsen-YUu9UAcOKZ4-unsplash_meyyk4.jpg",
  xavier: "https://res.cloudinary.com/dgcs9mj6j/image/upload/v1782409620/1645464920658_j9ij16.jpg"
}

# ==============================================================================
# IMAGE HELPERS
# ==============================================================================
def attach_photos(listing, urls, base_filename)
  urls.each_with_index do |url, i|
    next if url.blank? || url == "YOUR_URL_HERE"
    content = URI.open(url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36").read
    listing.photos.attach(
      io: StringIO.new(content),
      filename: "#{base_filename}_#{i + 1}.jpg",
      content_type: "image/jpeg"
    )
    puts "  ✓ #{base_filename} photo #{i + 1} attached"
  rescue => e
    puts "  ⚠ #{base_filename} photo #{i + 1} failed: #{e.message}"
  end
end

def attach_avatar(user, url)
  return if url.blank? || url == "YOUR_URL_HERE"
  content = URI.open(url, "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36").read
  user.avatar.attach(
    io: StringIO.new(content),
    filename: "#{user.first_name.downcase}_avatar.jpg",
    content_type: "image/jpeg"
  )
  puts "  ✓ Avatar attached for #{user.first_name}"
rescue => e
  puts "  ⚠ Avatar failed for #{user.first_name}: #{e.message}"
end

# ==============================================================================
# CLEANUP
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
# CATEGORIES
# ==============================================================================
puts "Creating categories..."
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

plumbing   = categories["plumbing, heating & ac"]
electrical = categories["electrical & smart home"]
carpentry  = categories["woodwork & carpentry"]

# ==============================================================================
# DEMO CONTRACTOR — James Carter
# ==============================================================================
puts "Creating James Carter (contractor)..."

james = User.create!(
  email: "contractor@demo.com",
  password: "password123",
  role: "contractor",
  first_name: "James",
  last_name: "Carter",
  bio: "10 years working in homes across London. Plumbing, electrics, carpentry, decorating. Fully insured and certified. Clean work, clear pricing.",
  street: "Oxford Street 100",
  postcode: "W1D 1LL",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5152,
  longitude: -0.1419
)

james.contractor_profile.update!(
  business_name: "Carter & Co. Home Services",
  business_website: "www.carterhomeservices.co.uk",
  travel_radius: 40,
  start_time: "08:00",
  end_time: "18:00",
  weekday_availability: "Mo,Tu,We,Th,Fr"
)

[plumbing, electrical, carpentry].each do |cat|
  Specialty.create!(user: james, category: cat)
end

puts "Attaching James's avatar..."
attach_avatar(james, AVATAR_PHOTOS[:james])

# ==============================================================================
# DEMO CUSTOMER — Xavier Mitchell
# ==============================================================================
puts "Creating Xavier Mitchell (customer)..."

xavier = User.create!(
  email: "xavierdcrn@gmail.com",
  password: "password123",
  role: "customer",
  first_name: "Xavier",
  last_name: "Mitchell",
  bio: "Homeowner in Notting Hill. I like working with people who are reliable and easy to communicate with.",
  street: "Portobello Road 22",
  postcode: "W11 1LU",
  city: "London",
  country: "United Kingdom",
  latitude: 51.5140,
  longitude: -0.2007
)

puts "Attaching Xavier's avatar..."
attach_avatar(xavier, AVATAR_PHOTOS[:xavier])

# ==============================================================================
# BACKGROUND CUSTOMERS
# ==============================================================================
puts "Creating background customers..."

emma = User.create!(
  email: "emma.clarke@example.com", password: "password123", role: "customer",
  first_name: "Emma", last_name: "Clarke",
  bio: "Renting in Brixton.",
  street: "Brixton Road 120", postcode: "SW9 7AA", city: "London", country: "United Kingdom",
  latitude: 51.4613, longitude: -0.1156
)

tom = User.create!(
  email: "tom.hughes@example.com", password: "password123", role: "customer",
  first_name: "Tom", last_name: "Hughes",
  bio: "Doing up a Victorian terrace in Hackney.",
  street: "Mare Street 45", postcode: "E8 3RH", city: "London", country: "United Kingdom",
  latitude: 51.5432, longitude: -0.0554
)

# ==============================================================================
# OPEN LISTINGS
# ==============================================================================
puts "Creating open listings..."

# Demo path A — fresh listing on the map, no offer from James
demo_listing_fresh = Listing.create!(
  user: xavier, category: plumbing,
  title: "Dripping tap and a small leak under the sink",
  description: "Our bathroom tap won't stop dripping and there's a damp patch inside the cabinet under the sink. We already have a new tap — just need someone to fit it and fix the leak underneath.",
  street: "Portobello Road 22", postcode: "W11 1LU", city: "London", country: "United Kingdom",
  latitude: 51.5140, longitude: -0.2007,
  urgency: "this_week",
  availability_profile: "completely_flexible",
  listing_status: "open",
  preferred_date_and_time: Time.current + 5.days
)
attach_photos(demo_listing_fresh, LISTING_PHOTOS[:tap_leak], "tap_leak")

# Demo path B — James has a pending offer, Xavier accepts this live
demo_listing_offered = Listing.create!(
  user: xavier, category: plumbing,
  title: "Boiler keeps losing pressure — small drip from a pipe underneath",
  description: "Our boiler loses pressure every few days and we keep having to top it up. There's also a small drip from one of the pipes below it. Need someone to fix the drip and sort out whatever is causing the pressure to drop.",
  street: "Portobello Road 22", postcode: "W11 1LU", city: "London", country: "United Kingdom",
  latitude: 51.5140, longitude: -0.2007,
  urgency: "this_week",
  availability_profile: "completely_flexible",
  listing_status: "open",
  preferred_date_and_time: Time.current + 4.days
)
attach_photos(demo_listing_offered, LISTING_PHOTOS[:boiler], "boiler")

demo_offer = Offer.create!(
  user: james,
  listing: demo_listing_offered,
  quote: 195,
  note: "Happy to come and sort this in one visit. I'll fix the drip, find out what's causing the pressure to drop, repressurise the boiler, and test everything before I leave. All parts included.",
  suggested_date_and_time: Time.current + 4.days,
  estimated_duration_hours: 2.0
)

Message.create!(offer: demo_offer, user: xavier, read: true,
  content: "Hi James, thanks for getting back so quickly! Does your price include any replacement parts if something needs swapping?")
Message.create!(offer: demo_offer, user: james, read: true,
  content: "Hi Xavier! Yes, all standard parts are included in the £195. If something bigger inside the boiler needs replacing I'd always check with you first.")
Message.create!(offer: demo_offer, user: xavier, read: false,
  content: "That's really reassuring, thank you. Let me check my diary and get back to you shortly!")

# Background listing 1 — Emma, electrical, Brixton
l_bg1 = Listing.create!(
  user: emma, category: electrical,
  title: "Two light switches stopped working, two others flickering",
  description: "Four switches in our flat have gone wrong — two are completely dead and two flicker constantly. We already have replacements, just need someone to swap them in safely.",
  street: "Brixton Road 120", postcode: "SW9 7AA", city: "London", country: "United Kingdom",
  latitude: 51.4613, longitude: -0.1156,
  urgency: "this_week",
  availability_profile: "workdays_daytime",
  listing_status: "open",
  preferred_date_and_time: Time.current + 6.days
)
attach_photos(l_bg1, LISTING_PHOTOS[:switches], "switches")

# Background listing 2 — Tom, carpentry, Hackney
l_bg2 = Listing.create!(
  user: tom, category: carpentry,
  title: "Two interior doors are stuck and one won't shut at all",
  description: "Two doors in our house have swollen badly over time. One won't close at all anymore. Need someone to shave them down and rehang them so they open and close normally.",
  street: "Mare Street 45", postcode: "E8 3RH", city: "London", country: "United Kingdom",
  latitude: 51.5432, longitude: -0.0554,
  urgency: "flexible",
  availability_profile: "after_hours_and_weekend",
  listing_status: "open",
  preferred_date_and_time: Time.current + 10.days
)
attach_photos(l_bg2, LISTING_PHOTOS[:doors], "doors")

# ==============================================================================
# COMPLETED JOB WITH REVIEW
# ==============================================================================
puts "Creating completed job and reviews..."

l_c1 = Listing.create!(
  user: emma, category: electrical,
  title: "Circuit breaker keeps tripping in the home office",
  description: "The circuit breaker for our home office trips daily for no obvious reason. Everything else in the flat is fine.",
  street: "Brixton Road 88", postcode: "SW9 7AB", city: "London", country: "United Kingdom",
  latitude: 51.4609, longitude: -0.1161,
  urgency: "this_week", availability_profile: "completely_flexible", listing_status: "closed"
)
attach_photos(l_c1, LISTING_PHOTOS[:completed_electrical], "completed_elec")

o_c1 = Offer.create!(
  user: james, listing: l_c1,
  quote: 145,
  offer_status: "accepted",
  note: "Full check of the circuit, fault found and fixed in the same visit. Safety certificate included.",
  suggested_date_and_time: 5.weeks.ago,
  estimated_duration_hours: 2.0
)
b_c1 = Booking.create!(
  offer: o_c1, listing: l_c1,
  booking_status: "completed",
  scheduled_date_and_time: 5.weeks.ago
)
Review.create!(booking: b_c1, user: emma, reviewee: james, rating: 5,
  content: "Found the problem within an hour and fixed it cleanly. The circuit hasn't tripped once since. Highly recommend.")
Review.create!(booking: b_c1, user: james, reviewee: emma, rating: 5,
  content: "Emma had already worked out which room the issue was in. Saved a lot of time. Really easy to work with.")

# ==============================================================================
# UPCOMING CONFIRMED BOOKING
# ==============================================================================
puts "Creating upcoming booking..."

l_u1 = Listing.create!(
  user: emma, category: electrical,
  title: "Six smart dimmers to fit across the whole flat",
  description: "All light switches need swapping for smart LED-compatible dimmers. Already purchased.",
  street: "Brixton Road 200", postcode: "SW9 7AC", city: "London", country: "United Kingdom",
  latitude: 51.4610, longitude: -0.1160,
  urgency: "this_week", availability_profile: "workdays_daytime", listing_status: "closed"
)
attach_photos(l_u1, LISTING_PHOTOS[:upcoming_dimmers], "upcoming_dimmers")

o_u1 = Offer.create!(
  user: james, listing: l_u1,
  quote: 320,
  offer_status: "accepted",
  note: "Replace all 6 switches. Safety certificate included.",
  suggested_date_and_time: Date.today.next_week(:monday).to_time + 9.hours,
  estimated_duration_hours: 3.0
)
Booking.create!(
  offer: o_u1, listing: l_u1,
  booking_status: "confirmed",
  scheduled_date_and_time: Date.today.next_week(:monday).to_time + 9.hours
)

# ==============================================================================
puts ""
puts "Seeds complete!"
puts "============================================"
puts "  CONTRACTOR:  contractor@demo.com"
puts "  CUSTOMER:    xavierdcrn@gmail.com"
puts "  PASSWORD:    password123 (both)"
puts "============================================"
