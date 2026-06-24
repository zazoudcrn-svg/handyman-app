class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent
    # Auto-mark notifications with deleted resources as read
    @notifications.each do |n|
      n.update(read: true) if n.resource.nil?
    end
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    @notification.update(read: true)
    @unread_count = current_user.notifications.unread.count

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("notification-badge",
          partial: "layouts/notification_badge",
          locals: { unread_count: @unread_count })
      end
      format.html { redirect_to request.referer || notifications_path }
    end
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read: true)
    redirect_back fallback_location: dashboard_path
  end
end
