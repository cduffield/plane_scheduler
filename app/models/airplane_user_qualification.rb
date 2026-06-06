class AirplaneUserQualification < ApplicationRecord
  belongs_to :airplane
  belongs_to :user
  belongs_to :checkout_event, class_name: "Event", optional: true
  belongs_to :approved_by, class_name: "User", optional: true

  validates :user_id, uniqueness: {scope: :airplane_id}

  def checkout_current_on?(date)
    checkout_completed_at.present? && (expires_on.blank? || expires_on >= date)
  end
end
