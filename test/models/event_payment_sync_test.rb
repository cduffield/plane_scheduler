require "test_helper"

class EventPaymentSyncTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:company)
    @user = users(:one)
    @airplane = @account.airplanes.create!(n_number: "N777ML", hobbs_time: 100.0, tach_time: 50.0, rate: 175.0)
    @event = @airplane.events.create!(
      user: @user,
      start_time: Time.zone.parse("2026-06-04 08:00"),
      end_time: Time.zone.parse("2026-06-04 10:00"),
      status: :closed,
      hobbs_start: 100.0,
      hobbs_end: 102.0,
      tach_start: 50.0,
      tach_end: 52.0
    )
    @event_payment = EventPayment.create!(event: @event, user: @user, amount: 350.0, currency: "usd", status: :pending)
    @pay_customer = Pay::Customer.create!(owner: @user, processor: "stripe", processor_id: "cus_security_test")
  end

  test "pay charge marks matching event payment paid" do
    charge = Pay::Charge.create!(
      customer: @pay_customer,
      processor_id: "ch_security_match",
      amount: 35_000,
      currency: "usd",
      metadata: matching_metadata
    )

    assert_equal "paid", @event_payment.reload.status
    assert_equal charge, @event_payment.pay_charge
    assert @event_payment.paid_at.present?
  end

  test "pay charge does not mark event payment paid when signed user reference does not match" do
    Pay::Charge.create!(
      customer: @pay_customer,
      processor_id: "ch_security_wrong_user",
      amount: 35_000,
      currency: "usd",
      metadata: matching_metadata.merge("user_ref" => users(:two).signed_id(purpose: :stripe_payment_metadata))
    )

    assert_equal "pending", @event_payment.reload.status
    assert_nil @event_payment.pay_charge
    assert_nil @event_payment.paid_at
  end

  test "pay charge does not mark event payment paid when amount does not match" do
    Pay::Charge.create!(
      customer: @pay_customer,
      processor_id: "ch_security_wrong_amount",
      amount: 1_00,
      currency: "usd",
      metadata: matching_metadata
    )

    assert_equal "pending", @event_payment.reload.status
    assert_nil @event_payment.pay_charge
    assert_nil @event_payment.paid_at
  end

  private

  def matching_metadata
    {
      "event_payment_id" => @event_payment.id.to_s,
      "event_id" => @event.id.to_s,
      "user_ref" => @user.signed_id(purpose: :stripe_payment_metadata)
    }
  end
end
