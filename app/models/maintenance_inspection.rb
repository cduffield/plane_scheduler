class MaintenanceInspection < ApplicationRecord
  belongs_to :airplane
  has_many :maintenance_inspection_events, dependent: :destroy

  enum :tracking_type, {
    calendar: 0,
    hours: 1,
    calendar_and_hours: 2
  }

  enum :calendar_interval_unit, {
    days: 0,
    months: 1
  }, prefix: true

  enum :hour_interval_type, {
    hobbs: 0,
    tach: 1
  }, prefix: true

  validates :name, presence: true
  validates :calendar_interval_value, presence: true, if: :calendar_tracking?
  validates :calendar_interval_unit, presence: true, if: :calendar_tracking?
  validates :hour_interval_value, presence: true, if: :hour_tracking?
  validates :hour_interval_type, presence: true, if: :hour_tracking?

  scope :active, -> { where(active: true) }

  def latest_event
    maintenance_inspection_events.order(performed_at: :desc).first
  end

  def next_calendar_due_at
    return unless calendar_tracking?
    return unless latest_event&.performed_at

    if calendar_interval_unit_days?
      latest_event.performed_at + calendar_interval_value.days
    else
      latest_event.performed_at + calendar_interval_value.months
    end
  end

  def next_hour_due
    return unless hour_tracking?
    return unless latest_event && hour_interval_value

    base_reading =
      if hour_interval_type_hobbs?
        latest_event.hobbs_time
      else
        latest_event.tach_time
      end

    return unless base_reading

    base_reading + hour_interval_value
  end

  def due_by_calendar?(reference_time = Time.current)
    due_at = next_calendar_due_at
    due_at.present? && due_at <= reference_time
  end

  def due_by_hours?
    due_reading = next_hour_due
    return false unless due_reading

    current_reading =
      if hour_interval_type_hobbs?
        airplane.hobbs_time
      else
        airplane.tach_time
      end

    current_reading.present? && current_reading >= due_reading
  end

  def due?(reference_time = Time.current)
    due_by_calendar?(reference_time) || due_by_hours?
  end

  def overdue?(reference_time = Time.current)
    due?(reference_time)
  end

  private

  def calendar_tracking?
    calendar? || calendar_and_hours?
  end

  def hour_tracking?
    hours? || calendar_and_hours?
  end
end
