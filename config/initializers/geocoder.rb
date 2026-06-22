# config/initializers/geocoder.rb
# Configuration to switch the geocoding provider to Mapbox using the environment variable token

Geocoder.configure(
  # Switch provider from OpenStreetMap to Mapbox
  lookup: :mapbox,

  # Fetch the access token securely from the local .env or Heroku config vars
  api_key: ENV['MAPBOX_API_KEY'],

  # System timeout in seconds to prevent blocking requests if the API lags
  timeout: 5,

  # Default distance units for routing calculations
  units: :km
)
