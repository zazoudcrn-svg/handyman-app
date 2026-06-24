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
    redirect_to request.referer || notifications_path
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read: true)
    redirect_back fallback_location: dashboard_path
  end
end
