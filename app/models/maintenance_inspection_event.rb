class MaintenanceInspectionEvent < ApplicationRecord
  belongs_to :maintenance_inspection

  validates :performed_at, presence: true
end
