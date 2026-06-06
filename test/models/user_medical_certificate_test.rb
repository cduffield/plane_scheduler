require "test_helper"

class UserMedicalCertificateTest < ActiveSupport::TestCase
  test "validates known medical certificate class" do
    certificate = users(:one).build_user_medical_certificate(
      medical_class: "third_class",
      certificate_number: "MED-123",
      issued_on: Date.new(2026, 1, 15),
      expires_on: Date.new(2028, 1, 31)
    )

    assert certificate.valid?
  end

  test "rejects unknown medical certificate class" do
    certificate = users(:one).build_user_medical_certificate(
      medical_class: "moon_class"
    )

    assert_not certificate.valid?
    assert_includes certificate.errors[:medical_class], "is not included in the list"
  end
end
