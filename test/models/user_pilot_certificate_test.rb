require "test_helper"

class UserPilotCertificateTest < ActiveSupport::TestCase
  test "validates known certificate category and class values" do
    certificate = users(:one).user_pilot_certificates.build(
      certificate_type: "private_pilot",
      category: "airplane",
      aircraft_class: "single_engine_land",
      certificate_number: "1234567",
      issued_on: Date.new(2022, 5, 14)
    )

    assert certificate.valid?
  end

  test "rejects unknown certificate values" do
    certificate = users(:one).user_pilot_certificates.build(
      certificate_type: "space_shuttle",
      category: "airplane",
      aircraft_class: "single_engine_land"
    )

    assert_not certificate.valid?
    assert_includes certificate.errors[:certificate_type], "is not included in the list"
  end
end
