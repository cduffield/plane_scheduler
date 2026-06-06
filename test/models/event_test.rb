require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @airplane = airplanes(:one)
    @other_airplane = airplanes(:two)
    @other_airplane.update!(account: @airplane.account)
    @instructor = users(:one)
    account_users(:one).update!(flight_instructor: true)
  end

  test "rejects overlapping booking for the same airplane" do
    existing = @airplane.events.create!(
      start_time: Time.zone.parse("2026-06-04 08:00"),
      end_time: Time.zone.parse("2026-06-04 10:00")
    )

    overlapping = @airplane.events.build(
      start_time: existing.start_time + 30.minutes,
      end_time: existing.end_time + 30.minutes
    )

    assert_not overlapping.valid?
    assert_includes overlapping.errors[:airplane], "is already booked for this time"
  end

  test "rejects overlapping booking for the same flight instructor across airplanes" do
    @airplane.events.create!(
      start_time: Time.zone.parse("2026-06-04 08:00"),
      end_time: Time.zone.parse("2026-06-04 10:00"),
      flight_instructor: @instructor
    )

    overlapping = @other_airplane.events.build(
      start_time: Time.zone.parse("2026-06-04 09:00"),
      end_time: Time.zone.parse("2026-06-04 11:00"),
      flight_instructor: @instructor
    )

    assert_not overlapping.valid?
    assert_includes overlapping.errors[:flight_instructor], "is already booked for this time"
  end

  test "rejects overlapping booking for the same user across airplanes" do
    pilot = users(:two)
    @airplane.events.create!(
      start_time: Time.zone.parse("2026-06-04 08:00"),
      end_time: Time.zone.parse("2026-06-04 10:00"),
      user: pilot
    )

    overlapping = @other_airplane.events.build(
      start_time: Time.zone.parse("2026-06-04 09:00"),
      end_time: Time.zone.parse("2026-06-04 11:00"),
      user: pilot
    )

    assert_not overlapping.valid?
    assert_includes overlapping.errors[:user], "is already booked for this time"
  end

  test "allows back to back bookings" do
    @airplane.events.create!(
      start_time: Time.zone.parse("2026-06-04 08:00"),
      end_time: Time.zone.parse("2026-06-04 10:00"),
      flight_instructor: @instructor
    )

    next_event = @airplane.events.build(
      start_time: Time.zone.parse("2026-06-04 10:00"),
      end_time: Time.zone.parse("2026-06-04 12:00"),
      flight_instructor: @instructor,
      user: users(:two)
    )

    assert next_event.valid?
  end

  test "ignores cancelled events when checking booking conflicts" do
    @airplane.events.create!(
      start_time: Time.zone.parse("2026-06-04 08:00"),
      end_time: Time.zone.parse("2026-06-04 10:00"),
      flight_instructor: @instructor,
      user: users(:two),
      status: :cancelled
    )

    overlapping = @airplane.events.build(
      start_time: Time.zone.parse("2026-06-04 09:00"),
      end_time: Time.zone.parse("2026-06-04 11:00"),
      flight_instructor: @instructor,
      user: users(:two)
    )

    assert overlapping.valid?
  end

  test "requires instructor when user is not solo eligible for airplane" do
    @airplane.create_airplane_solo_requirement!(requires_checkout: true, active: true)

    event = @airplane.events.build(
      start_time: Time.zone.parse("2026-06-04 13:00"),
      end_time: Time.zone.parse("2026-06-04 15:00"),
      user: users(:two)
    )

    assert_not event.valid?
    assert_includes event.errors[:base], "Book this aircraft with an instructor until solo requirements are met: checkout flight"
  end

  test "allows instructional booking when user is not solo eligible" do
    @airplane.create_airplane_solo_requirement!(requires_checkout: true, active: true)

    event = @airplane.events.build(
      start_time: Time.zone.parse("2026-06-04 13:00"),
      end_time: Time.zone.parse("2026-06-04 15:00"),
      user: users(:two),
      flight_instructor: @instructor
    )

    assert event.valid?, event.errors.full_messages.inspect
  end
end
