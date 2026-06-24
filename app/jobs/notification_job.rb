class NotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_type, recipient, resource = nil)
    # 1. Send email
    begin
      case notification_type
      when "new_match"
        NotificationMailer.new_match(recipient, resource).deliver_now
      when "welcome"
        NotificationMailer.welcome(recipient).deliver_now
      when "new_message"
        NotificationMailer.new_message(resource, recipient).deliver_now
      else
        NotificationMailer.send(notification_type, resource).deliver_now
      end
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
