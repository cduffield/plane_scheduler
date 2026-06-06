module StripeConnect
  class DirectCheckoutSession
    def self.create(...)
      new(...).create
    end

    def initialize(event_payment:, event:, user:, connected_account_id:, checkout_name:, success_url:, cancel_url:)
      @event_payment = event_payment
      @event = event
      @user = user
      @connected_account_id = connected_account_id
      @checkout_name = checkout_name
      @success_url = success_url
      @cancel_url = cancel_url
    end

    def create
      Stripe::Checkout::Session.create(checkout_params, stripe_options)
    end

    private

    attr_reader :event_payment, :event, :user, :connected_account_id, :checkout_name, :success_url, :cancel_url

    def checkout_params
      {
        mode: "payment",
        customer_email: user.email,
        success_url: success_url,
        cancel_url: cancel_url,
        line_items: [
          {
            price_data: {
              currency: event_payment.currency,
              product_data: { name: checkout_name },
              unit_amount: amount_in_cents
            },
            quantity: 1
          }
        ],
        payment_intent_data: {
          metadata: {
            event_payment_id: event_payment.id.to_s,
            event_id: event.id.to_s,
            user_id: user.id.to_s
          }
        }
      }
    end

    def stripe_options
      { stripe_account: connected_account_id }
    end

    def amount_in_cents
      (event_payment.amount * 100).round
    end
  end
end
