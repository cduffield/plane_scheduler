class AirplaneSoloRequirement < ApplicationRecord
  belongs_to :airplane

  validates :required_certificate_type, inclusion: {in: UserPilotCertificate::CERTIFICATE_TYPES.keys}, allow_blank: true
  validates :required_rating_type, inclusion: {in: UserPilotCertificate::CERTIFICATE_TYPES.keys}, allow_blank: true
  validates :recent_rental_days, numericality: {only_integer: true, greater_than: 0}, allow_blank: true

  def required_certificate_type_label = UserPilotCertificate::CERTIFICATE_TYPES[required_certificate_type]

  def required_rating_type_label = UserPilotCertificate::CERTIFICATE_TYPES[required_rating_type]
end
