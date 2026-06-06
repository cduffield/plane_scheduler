Pay.setup do |config|
  config.application_name = Jumpstart.config.application_name
  config.business_name = Jumpstart.config.business_name
  config.business_address = Jumpstart.config.business_address
  config.support_email = Jumpstart.config.support_email

  config.routes_path = "/"

  config.mail_to = -> {
    pay_customer = params[:pay_customer]
    owner = pay_customer.owner

    recipients = []
    if owner.is_a?(Account)
      recipients << ActionMailer::Base.email_address_with_name(owner.owner.email, pay_customer.customer_name)
      recipients << owner.billing_email if owner.billing_email?
    elsif owner.respond_to?(:email) && owner.email.present?
      recipients << ActionMailer::Base.email_address_with_name(owner.email, pay_customer.customer_name)
    end
    recipients
  }
end

# Use Inter font for full UTF-8 support in PDFs
# https://github.com/rsms/inter
Receipts.default_font = {
  bold: Jumpstart::Engine.root.join("app/assets/fonts/Inter-Bold.ttf"),
  normal: Jumpstart::Engine.root.join("app/assets/fonts/Inter-Regular.ttf")
}

ActiveSupport.on_load :pay_subscription do
  has_prefix_id :sub
  delegate :currency, to: :plan

  def plan
    @plan ||= Plan.where("#{customer.processor}_id": processor_plan).first
  end

  def amount
    (quantity == 0) ? plan.amount : plan.amount * quantity
  end
end

ActiveSupport.on_load :pay_charge do
  has_prefix_id :ch
  after_create :complete_referral, if: -> { defined?(Refer) }
  after_commit :sync_event_payment, on: :create

  # Mark the account owner's referral complete on the first successful payment
  def complete_referral
    owner = customer.owner
    referral_owner = owner.is_a?(Account) ? owner.owner : owner
    referral_owner&.referral&.complete!
  end

  def sync_event_payment
    metadata_hash = metadata.to_h
    event_payment_id = metadata_hash["event_payment_id"]
    return if event_payment_id.blank?

    event_payment = EventPayment.find_by(id: event_payment_id)
    return if event_payment.blank?
    return unless metadata_hash["event_id"].to_s == event_payment.event_id.to_s
    return unless User.find_signed(metadata_hash["user_ref"], purpose: :stripe_payment_metadata) == event_payment.user
    return unless amount.to_i == (event_payment.amount * 100).round
    return unless currency.to_s.downcase == event_payment.currency.to_s.downcase

    event_payment.update(
      pay_charge: self,
      status: :paid,
      paid_at: Time.current
    )
  end
end
