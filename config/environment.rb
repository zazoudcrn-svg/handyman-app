# Load the Rails application.
require_relative "application"

Rails.application.configure do
  config.active_storage.service = :cloudinary
end

# Initialize the Rails application.
Rails.application.initialize!
