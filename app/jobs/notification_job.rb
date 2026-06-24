class NotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_type, recipient, resource = nil)
    # 1. Send email
    begin
      NotificationMailer.send(notification_type, resource).deliver_now
    rescue => e
      Rails.logger.error "Mailer error: #{e.message}"
    end

    # 2. Create in-app notification (not for welcome email)
    unless notification_type == "welcome"
      Notification.create!(
        user: recipient,
        notification_type: notification_type.to_s,
        resource: resource
      )
    end
  end
end
