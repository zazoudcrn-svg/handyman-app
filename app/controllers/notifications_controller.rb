class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent
    @notifications.unread.update_all(read: true)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read: true)
    redirect_back fallback_location: dashboard_path
  end
end
