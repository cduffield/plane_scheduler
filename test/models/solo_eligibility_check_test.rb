require "test_helper"

class SoloEligibilityCheckTest < ActiveSupport::TestCase
  setup do
    @airplane = airplanes(:one)
    @user = users(:two)
  end

  test "eligible when airplane has no active solo requirement" do
    check = SoloEligibilityCheck.new(user: @user, airplane: @airplane, start_time: Time.zone.parse("2026-06-04 10:00"))

    assert check.eligible?
    assert_empty check.errors
  end

  test "requires checkout when configured" do
    @airplane.create_airplane_solo_requirement!(requires_checkout: true, active: true)
    check = SoloEligibilityCheck.new(user: @user, airplane: @airplane, start_time: Time.zone.parse("2026-06-04 10:00"))

    assert_not check.eligible?
    assert_includes check.errors, "checkout flight"
  end

  test "requires configured certificate and recent rental" do
    @airplane.create_airplane_solo_requirement!(
      requires_checkout: true,
      required_certificate_type: "private_pilot",
      recent_rental_days: 90,
      active: true
    )
    @airplane.airplane_user_qualifications.create!(user: @user, checkout_completed_at: Date.new(2026, 1, 1))
    @user.user_pilot_certificates.create!(
      certificate_type: "private_pilot",
      category: "airplane",
      aircraft_class: "single_engine_land"
    )
    @airplane.events.create!(
      user: @user,
      start_time: Time.zone.parse("2026-05-01 10:00"),
      end_time: Time.zone.parse("2026-05-01 12:00"),
      hobbs_end: 11.0,
      tach_end: 11.0,
      status: :closed
    )

    check = SoloEligibilityCheck.new(user: @user, airplane: @airplane, start_time: Time.zone.parse("2026-06-04 10:00"))

    assert check.eligible?, check.errors.inspect
  end

  test "rejects expired recent rental requirement" do
    @airplane.create_airplane_solo_requirement!(recent_rental_days: 30, active: true)
    @airplane.events.create!(
      user: @user,
      start_time: Time.zone.parse("2026-04-01 10:00"),
      end_time: Time.zone.parse("2026-04-01 12:00"),
      hobbs_end: 11.0,
      tach_end: 11.0,
      status: :closed
    )

    check = SoloEligibilityCheck.new(user: @user, airplane: @airplane, start_time: Time.zone.parse("2026-06-04 10:00"))

    assert_not check.eligible?
    assert_includes check.errors, "rental in the last 30 days"
  end
end
