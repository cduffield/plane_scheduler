class User < ApplicationRecord
  PILOT_CERTIFICATES = {
    "student" => "Student",
    "private_pilot" => "Private pilot",
    "instrument_rating" => "Instrument rating",
    "commercial_pilot" => "Commercial pilot",
    "atp" => "ATP",
    "cfi" => "CFI",
    "cfii" => "CFII",
    "mei" => "MEI"
  }.freeze

  AIRCRAFT_CATEGORIES = {
    "airplane" => "Airplane",
    "rotorcraft" => "Rotorcraft",
    "glider" => "Glider",
    "lighter_than_air" => "Lighter-than-air",
    "powered_lift" => "Powered lift",
    "powered_parachute" => "Powered parachute",
    "weight_shift_control" => "Weight-shift control"
  }.freeze

  AIRCRAFT_CLASSES = {
    "single_engine_land" => "Single-engine land",
    "multi_engine_land" => "Multi-engine land",
    "single_engine_sea" => "Single-engine sea",
    "multi_engine_sea" => "Multi-engine sea",
    "helicopter" => "Helicopter",
    "gyroplane" => "Gyroplane",
    "airship" => "Airship",
    "balloon" => "Balloon"
  }.freeze

  pay_customer

  include Accounts, Agreements, Authenticatable, Mentions, Notifiable, Profile, Searchable, Theme

  has_many :event_payments, dependent: :destroy
  has_many :user_pilot_certificates, dependent: :destroy
  has_one :user_medical_certificate, dependent: :destroy
  accepts_nested_attributes_for :user_pilot_certificates, allow_destroy: true, reject_if: :blank_pilot_certificate
  accepts_nested_attributes_for :user_medical_certificate, update_only: true, reject_if: :blank_medical_certificate

  before_validation :normalize_pilot_qualifications

  validate :pilot_qualifications_are_known
  validates :total_time, :pic_time, :sic_time, :cross_country_time, :instrument_time,
    :night_time, :simulator_time, :dual_received_time, :solo_time,
    numericality: {greater_than_or_equal_to: 0}

  def system_theme? = false

  def dark_theme? = false

  def light_theme? = true

  def pilot_certificate_labels
    pilot_certificates.map { |value| PILOT_CERTIFICATES[value] }.compact
  end

  def aircraft_category_labels
    aircraft_categories.map { |value| AIRCRAFT_CATEGORIES[value] }.compact
  end

  def aircraft_class_labels
    aircraft_classes.map { |value| AIRCRAFT_CLASSES[value] }.compact
  end

  private

  def blank_pilot_certificate(attributes)
    attributes["certificate_type"].blank? &&
      attributes["category"].blank? &&
      attributes["aircraft_class"].blank? &&
      attributes["certificate_number"].blank? &&
      attributes["issued_on"].blank?
  end

  def blank_medical_certificate(attributes)
    attributes["medical_class"].blank? &&
      attributes["certificate_number"].blank? &&
      attributes["issued_on"].blank? &&
      attributes["expires_on"].blank?
  end

  def normalize_pilot_qualifications
    self.pilot_certificates = normalized_values(pilot_certificates)
    self.aircraft_categories = normalized_values(aircraft_categories)
    self.aircraft_classes = normalized_values(aircraft_classes)
  end

  def normalized_values(values)
    Array(values).map(&:presence).compact.uniq
  end

  def pilot_qualifications_are_known
    add_unknown_qualification_error(:pilot_certificates, PILOT_CERTIFICATES)
    add_unknown_qualification_error(:aircraft_categories, AIRCRAFT_CATEGORIES)
    add_unknown_qualification_error(:aircraft_classes, AIRCRAFT_CLASSES)
  end

  def add_unknown_qualification_error(attribute, allowed_values)
    return if public_send(attribute).all? { |value| allowed_values.key?(value) }

    errors.add(attribute, "contains an unknown option")
  end
end
