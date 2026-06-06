class Event < ApplicationRecord
  belongs_to :airplane
  belongs_to :user, optional: true
  belongs_to :flight_instructor, class_name: "User", optional: true
  has_many :event_payments, dependent: :destroy

  enum :status, {scheduled: 0, open: 1, closed: 2, cancelled: 3}

  before_validation :set_start_times_from_airplane, on: :create
  before_validation :set_total_cost, if: :closed?

  validate :end_time_after_start_time
  validate :end_readings_present_when_closed
  validate :end_readings_after_start_readings
  validate :flight_instructor_belongs_to_airplane_account
  validate :airplane_is_available
  validate :flight_instructor_is_available
  validate :user_is_available
  validate :user_is_solo_eligible_or_has_instructor

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

  def flight_instructor_belongs_to_airplane_account
    return if flight_instructor_id.blank? || airplane&.account.blank?

    return if airplane.account.account_users.flight_instructor.exists?(user_id: flight_instructor_id)

    errors.add(:flight_instructor, "must be a flight instructor in this account")
  end

  def airplane_is_available
    return if airplane_id.blank? || start_time.blank? || end_time.blank?

    if overlapping_events.where(airplane_id:).exists?
      errors.add(:airplane, "is already booked for this time")
    end
  end

  def flight_instructor_is_available
    return if flight_instructor_id.blank? || start_time.blank? || end_time.blank?

    if overlapping_events.where(flight_instructor_id:).exists?
      errors.add(:flight_instructor, "is already booked for this time")
    end
  end

  def user_is_available
    return if user_id.blank? || start_time.blank? || end_time.blank?

    if overlapping_events.where(user_id:).exists?
      errors.add(:user, "is already booked for this time")
    end
  end

  def user_is_solo_eligible_or_has_instructor
    return unless scheduled?
    return if flight_instructor_id.present? || airplane.blank?

    check = SoloEligibilityCheck.new(user:, airplane:, start_time:)
    return if check.eligible?

    errors.add(:base, "Book this aircraft with an instructor until solo requirements are met: #{check.errors.join(", ")}")
  end

  def overlapping_events
    Event
      .where.not(id: id)
      .where.not(status: Event.statuses[:cancelled])
      .where("start_time < ? AND end_time > ?", end_time, start_time)
  end
end
