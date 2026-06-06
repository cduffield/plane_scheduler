class EventPaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: :create

  def index
    payments = current_user.event_payments
      .joins(event: :airplane)
      .where(airplanes: { account_id: current_account.id })
      .includes(event: :airplane)
      .order(created_at: :desc)
    @unpaid_event_payments = payments.reject(&:paid?)
    @paid_event_payments = payments.select(&:paid?)
  end

  def create
    unless Jumpstart.config.stripe?
      redirect_to @event, alert: "Stripe payments are not enabled."
      return
    end

    unless @event.closed?
      redirect_to @event, alert: "Only closed flights can be paid."
      return
    end

    if @event.total_cost.blank? || @event.total_cost <= 0
      redirect_to @event, alert: "This event does not have a payable total cost yet."
      return
    end

    merchant = current_account.merchant_processor
    unless merchant&.processor_id.present? && merchant.onboarding_complete?
      redirect_to @event, alert: "Connect Stripe for this account before accepting flight payments."
      return
    end

    @event_payment = EventPayment.find_or_initialize_by(event: @event, user: current_user)

    if @event_payment.paid?
      redirect_to @event, notice: "This event has already been paid."
      return
    end

    @event_payment.assign_attributes(
      amount: @event.total_cost,
      currency: "usd",
      status: :pending,
      paid_at: nil,
      pay_charge: nil
    )
    @event_payment.save!

    checkout_session = StripeConnect::DirectCheckoutSession.create(
      event_payment: @event_payment,
      event: @event,
      user: current_user,
      connected_account_id: merchant.processor_id,
      checkout_name: checkout_name,
      success_url: checkout_return_url(return_to: event_url(@event)),
      cancel_url: event_url(@event)
    )

    if checkout_session.url.blank?
      redirect_to @event, alert: "Stripe checkout session was created without a redirect URL."
      return
    end

    @event_payment.update!(stripe_checkout_session_id: checkout_session.id)
    redirect_to checkout_session.url, allow_other_host: true, status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    redirect_to @event, alert: e.record.errors.full_messages.to_sentence
  rescue Stripe::StripeError => e
    redirect_to @event, alert: e.message
  rescue Pay::Error => e
    redirect_to @event, alert: e.message
  end

  private

  def set_event
    @event = current_account.events.find(params.expect(:event_id))
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path
  end

  def checkout_name
    airplane_name = @event.airplane&.n_number.presence || "Event ##{@event.id}"
    "Flight payment for #{airplane_name}"
  end
end
