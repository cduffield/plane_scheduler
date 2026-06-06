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
          flight_instructor_id: instructor_membership.user_id
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
          flight_instructor_id: outside_instructor.id
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

  test "should destroy event" do
    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_url
  end
end
