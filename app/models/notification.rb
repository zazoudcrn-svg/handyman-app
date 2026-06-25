class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :resource, polymorphic: true, optional: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }

  after_initialize :set_defaults

  private

  def set_defaults
    self.read = false if read.nil?
  end
end
