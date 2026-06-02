class Event < ApplicationRecord
  belongs_to :airplane
  has_many :event_payments, dependent: :destroy

  enum :status, { scheduled: 0, open: 1, closed: 2, cancelled: 3 }

  before_validation :set_start_times_from_airplane, on: :create
  before_validation :set_total_cost, if: :closed?

  validate :end_time_after_start_time
  validate :end_readings_present_when_closed
  validate :end_readings_after_start_readings

  private

  def set_start_times_from_airplane
    return if airplane.blank?

    self.hobbs_start ||= airplane.hobbs_time
    self.tach_start ||= airplane.tach_time
  end

  def set_total_cost
    return if airplane.blank? || airplane.rate.blank? || hobbs_start.blank? || hobbs_end.blank?

    self.total_cost = (hobbs_end - hobbs_start) * airplane.rate
  end

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def end_readings_after_start_readings
    if hobbs_start.present? && hobbs_end.present? && hobbs_end < hobbs_start
      errors.add(:hobbs_end, "must be greater than or equal to hobbs start")
    end

    if tach_start.present? && tach_end.present? && tach_end < tach_start
      errors.add(:tach_end, "must be greater than or equal to tach start")
    end
  end

  def end_readings_present_when_closed
    return unless closed?

    errors.add(:hobbs_end, "can't be blank") if hobbs_end.blank?
    errors.add(:tach_end, "can't be blank") if tach_end.blank?
  end
end
