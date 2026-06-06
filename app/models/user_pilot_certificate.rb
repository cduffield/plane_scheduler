class UserPilotCertificate < ApplicationRecord
  belongs_to :user

  CERTIFICATE_TYPES = {
    "student" => "Student Pilot",
    "private_pilot" => "Private Pilot",
    "instrument_rating" => "Instrument Rating",
    "commercial_pilot" => "Commercial Pilot",
    "atp" => "Airline Transport Pilot (ATP)",
    "cfi" => "Certified Flight Instructor (CFI)",
    "cfii" => "Certified Flight Instructor - Instrument (CFII)",
    "mei" => "Multi-Engine Instructor (MEI)"
  }.freeze

  CATEGORIES = {
    "airplane" => "Airplane",
    "rotorcraft" => "Rotorcraft",
    "glider" => "Glider",
    "lighter_than_air" => "Lighter-than-Air",
    "powered_lift" => "Powered-Lift"
  }.freeze

  CLASSES = {
    "single_engine_land" => "Single-Engine Land (ASE)",
    "multi_engine_land" => "Multi-Engine Land (AME)",
    "single_engine_sea" => "Single-Engine Sea (ASES)",
    "multi_engine_sea" => "Multi-Engine Sea (AMES)",
    "helicopter" => "Helicopter",
    "gyroplane" => "Gyroplane",
    "airship" => "Airship",
    "balloon" => "Balloon"
  }.freeze

  validates :certificate_type, presence: true, inclusion: {in: CERTIFICATE_TYPES.keys}
  validates :category, presence: true, inclusion: {in: CATEGORIES.keys}
  validates :aircraft_class, presence: true, inclusion: {in: CLASSES.keys}

  def certificate_type_label = CERTIFICATE_TYPES[certificate_type]

  def category_label = CATEGORIES[category]

  def aircraft_class_label = CLASSES[aircraft_class]
end
