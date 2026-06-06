require "test_helper"
require "ostruct"

class EventPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:company)
    @user = users(:one)
    sign_in @user
    switch_account @account

    @airplane = @account.airplanes.create!(n_number: "N101ML", hobbs_time: 100.0, tach_time: 50.0, rate: 175.0)
    @event = @airplane.events.create!(
      start_time: Time.zone.parse("2026-06-03 08:00"),
      end_time: Time.zone.parse("2026-06-03 10:00"),
      status: :closed,
      hobbs_start: 100.0,
      hobbs_end: 102.0,
      tach_start: 50.0,
      tach_end: 52.0,
      user: @user
    )
  end

  test "redirects when team has not connected Stripe" do
    post event_payment_path(@event)

    assert_redirected_to event_path(@event)
    assert_equal "Connect Stripe for this account before accepting flight payments.", flash[:alert]
  end

  test "creates direct charge checkout session on team connected account" do
    @account.set_merchant_processor(:stripe, processor_id: "acct_test_123", data: {onboarding_complete: true})
    fake_session = OpenStruct.new(id: "cs_test_123", url: "https://checkout.stripe.test/session")

    StripeConnect::DirectCheckoutSession.stub(:create, fake_session) do
      post event_payment_path(@event)
    end

    event_payment = EventPayment.find_by!(event: @event, user: @user)
    assert_equal "cs_test_123", event_payment.stripe_checkout_session_id
    assert_redirected_to "https://checkout.stripe.test/session"
  end

  test "does not create checkout session for another user's event" do
    @account.set_merchant_processor(:stripe, processor_id: "acct_test_123", data: {onboarding_complete: true})
    sign_out @user
    sign_in users(:two)
    switch_account @account

    assert_no_difference("EventPayment.count") do
      post event_payment_path(@event)
    end

    assert_redirected_to event_path(@event)
    assert_equal "You can only pay for your own flight.", flash[:alert]
  end
end
