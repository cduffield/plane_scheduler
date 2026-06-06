class UserMedicalCertificate < ApplicationRecord
  belongs_to :user

  MEDICAL_CLASSES = {
    "first_class" => "First Class",
    "second_class" => "Second Class",
    "third_class" => "Third Class",
    "basic_med" => "BasicMed"
  }.freeze

  validates :medical_class, presence: true, inclusion: { in: MEDICAL_CLASSES.keys }

  def medical_class_label = MEDICAL_CLASSES[medical_class]
end
