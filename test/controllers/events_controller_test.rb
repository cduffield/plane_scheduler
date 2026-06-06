require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = events(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get events_url
    assert_response :success
  end

  test "should get new" do
    account_users(:company_regular_user).update!(flight_instructor: true)
    switch_account(accounts(:company))

    get new_event_url

    assert_response :success
    assert_select "select[name='event[flight_instructor_id]'] option", text: users(:two).name
    assert_select "select[name='event[flight_instructor_id]'] option[value='#{users(:two).id}']", count: 0
  end

  test "should create event" do
    assert_difference("Event.count") do
      post events_url, params: {
        event: {
          airplane_id: @event.airplane_id,
          start_time: Time.zone.parse("2026-02-13 18:00"),
          end_time: Time.zone.parse("2026-02-13 20:00")
        }
      }
    end

    assert_redirected_to event_url(Event.last)
    assert_equal users(:one), Event.last.user
  end

  test "should create event with flight instructor from current account" do
    instructor_membership = account_users(:company_regular_user)
    instructor_membership.update!(flight_instructor: true)
    airplane = airplanes(:one)
    airplane.update!(account: accounts(:company))
    switch_account(accounts(:company))

    assert_difference("Event.count") do
      post events_url, params: {
        event: {
          airplane_id: airplane.id,
          start_time: Time.zone.parse("2026-02-13 18:00"),
          end_time: Time.zone.parse("2026-02-13 20:00"),
          flight_instructor_id: instructor_membership.user.signed_id(purpose: :event_flight_instructor)
        }
      }
    end

    assert_redirected_to event_url(Event.last)
    assert_equal instructor_membership.user, Event.last.flight_instructor
  end

  test "should not create event with flight instructor outside current account" do
    outside_instructor = users(:two)

    assert_no_difference("Event.count") do
      post events_url, params: {
        event: {
          airplane_id: @event.airplane_id,
          start_time: @event.start_time,
          end_time: @event.end_time,
          flight_instructor_id: outside_instructor.signed_id(purpose: :event_flight_instructor)
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should not create event with raw flight instructor id" do
    instructor_membership = account_users(:company_regular_user)
    instructor_membership.update!(flight_instructor: true)
    airplane = airplanes(:one)
    airplane.update!(account: accounts(:company))
    switch_account(accounts(:company))

    assert_no_difference("Event.count") do
      post events_url, params: {
        event: {
          airplane_id: airplane.id,
          start_time: Time.zone.parse("2026-02-13 18:00"),
          end_time: Time.zone.parse("2026-02-13 20:00"),
          flight_instructor_id: instructor_membership.user_id
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should show event" do
    get event_url(@event)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_url(@event)
    assert_response :success
  end

  test "should update event" do
    patch event_url(@event), params: { event: { airplane_id: @event.airplane_id, end_time: @event.end_time, start_time: @event.start_time } }
    assert_redirected_to event_url(@event)
  end

  test "regular account member cannot edit another user's event" do
    account = accounts(:company)
    airplane = account.airplanes.create!(n_number: "N202ML", hobbs_time: 10, tach_time: 5, rate: 100)
    event = airplane.events.create!(
      user: users(:one),
      start_time: Time.zone.parse("2026-03-01 08:00"),
      end_time: Time.zone.parse("2026-03-01 10:00")
    )
    sign_out users(:one)
    sign_in users(:two)
    switch_account account

    get edit_event_url(event)

    assert_redirected_to event_url(event)
    assert_equal "You are not allowed to modify this event.", flash[:alert]
  end

  test "regular account member cannot update another user's event" do
    account = accounts(:company)
    airplane = account.airplanes.create!(n_number: "N303ML", hobbs_time: 10, tach_time: 5, rate: 100)
    event = airplane.events.create!(
      user: users(:one),
      start_time: Time.zone.parse("2026-03-02 08:00"),
      end_time: Time.zone.parse("2026-03-02 10:00")
    )
    sign_out users(:one)
    sign_in users(:two)
    switch_account account

    patch event_url(event), params: { event: { airplane_id: airplane.id, start_time: event.start_time, end_time: event.end_time + 1.hour } }

    assert_redirected_to event_url(event)
    assert_equal "You are not allowed to modify this event.", flash[:alert]
    assert_equal Time.zone.parse("2026-03-02 10:00"), event.reload.end_time
  end

  test "regular account member cannot destroy another user's event" do
    account = accounts(:company)
    airplane = account.airplanes.create!(n_number: "N404ML", hobbs_time: 10, tach_time: 5, rate: 100)
    event = airplane.events.create!(
      user: users(:one),
      start_time: Time.zone.parse("2026-03-03 08:00"),
      end_time: Time.zone.parse("2026-03-03 10:00")
    )
    sign_out users(:one)
    sign_in users(:two)
    switch_account account

    assert_no_difference("Event.count") do
      delete event_url(event)
    end

    assert_redirected_to event_url(event)
    assert_equal "You are not allowed to modify this event.", flash[:alert]
  end

  test "assigned flight instructor can edit event" do
    account = accounts(:company)
    instructor_membership = account_users(:company_regular_user)
    instructor_membership.update!(flight_instructor: true)
    airplane = account.airplanes.create!(n_number: "N505ML", hobbs_time: 10, tach_time: 5, rate: 100)
    event = airplane.events.create!(
      user: users(:one),
      flight_instructor: users(:two),
      start_time: Time.zone.parse("2026-03-04 08:00"),
      end_time: Time.zone.parse("2026-03-04 10:00")
    )
    sign_out users(:one)
    sign_in users(:two)
    switch_account account

    get edit_event_url(event)

    assert_response :success
  end

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_url
  end
end
