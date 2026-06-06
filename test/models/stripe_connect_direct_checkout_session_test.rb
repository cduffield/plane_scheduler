require "test_helper"
require "ostruct"

class StripeConnectDirectCheckoutSessionTest < ActiveSupport::TestCase
  test "creates checkout session on connected account for direct charge" do
    event_payment = EventPayment.new(id: 123, amount: 350.25, currency: "usd")
    event = Event.new(id: 456)
    user = users(:one)
    session = OpenStruct.new(id: "cs_test_123", url: "https://checkout.stripe.test/session")

    captured_params = nil
    captured_options = nil

    Stripe::Checkout::Session.stub(:create, ->(params, options) {
      captured_params = params
      captured_options = options
      session
    }) do
      result = StripeConnect::DirectCheckoutSession.create(
        event_payment: event_payment,
        event: event,
        user: user,
        connected_account_id: "acct_test_123",
        checkout_name: "Flight payment for N101ML",
        success_url: "https://example.test/success",
        cancel_url: "https://example.test/cancel"
      )

      assert_equal session, result
    end

    assert_equal({ stripe_account: "acct_test_123" }, captured_options)
    assert_equal "payment", captured_params[:mode]
    assert_equal "https://example.test/success", captured_params[:success_url]
    assert_equal "https://example.test/cancel", captured_params[:cancel_url]
    assert_equal 35_025, captured_params[:line_items].first[:price_data][:unit_amount]
    assert_equal "usd", captured_params[:line_items].first[:price_data][:currency]
    assert_equal "Flight payment for N101ML", captured_params[:line_items].first[:price_data][:product_data][:name]
    assert_equal "123", captured_params[:payment_intent_data][:metadata][:event_payment_id]
    assert_equal "456", captured_params[:payment_intent_data][:metadata][:event_id]
    assert_nil captured_params[:payment_intent_data][:metadata][:user_id]
    assert_equal user, User.find_signed(captured_params[:payment_intent_data][:metadata][:user_ref], purpose: :stripe_payment_metadata)
  end
end
