class AccountAdminPaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_account_admin
  before_action :set_merchant
  before_action :refresh_connected_account_status, only: :show

  def show
  end

  def create
    merchant = current_account.merchant_processor || current_account.set_merchant_processor(:stripe)
    merchant.create_account(type: "standard", email: current_account.owner.email) if merchant.processor_id.blank?

    account_link = merchant.account_link(
      refresh_url: account_admin_payments_url,
      return_url: account_admin_payments_url
    )

    redirect_to account_link.url, allow_other_host: true, status: :see_other
  rescue Pay::Error => e
    redirect_to account_admin_payments_path, alert: e.message
  end

  private

  def set_merchant
    @merchant = current_account.merchant_processor
  end

  def refresh_connected_account_status
    return unless @merchant&.processor_id.present?

    stripe_account = @merchant.account
    requirements = stripe_account_value(stripe_account, :requirements)
    currently_due = stripe_account_value(requirements, :currently_due) || []
    eventually_due = stripe_account_value(requirements, :eventually_due) || []
    past_due = stripe_account_value(requirements, :past_due) || []

    @stripe_connect_status = {
      charges_enabled: stripe_account_value(stripe_account, :charges_enabled),
      payouts_enabled: stripe_account_value(stripe_account, :payouts_enabled),
      details_submitted: stripe_account_value(stripe_account, :details_submitted),
      currently_due: currently_due,
      eventually_due: eventually_due,
      past_due: past_due,
      disabled_reason: stripe_account_value(requirements, :disabled_reason)
    }

    @merchant.update!(
      data: (@merchant.data || {}).merge(
        "onboarding_complete" => @stripe_connect_status[:charges_enabled],
        "charges_enabled" => @stripe_connect_status[:charges_enabled],
        "payouts_enabled" => @stripe_connect_status[:payouts_enabled],
        "details_submitted" => @stripe_connect_status[:details_submitted],
        "currently_due" => currently_due,
        "eventually_due" => eventually_due,
        "past_due" => past_due,
        "disabled_reason" => @stripe_connect_status[:disabled_reason]
      )
    )
  rescue Pay::Error => e
    @stripe_connect_error = e.message
  end

  def stripe_account_value(object, key)
    return nil if object.blank?
    return object.public_send(key) if object.respond_to?(key)
    object[key.to_s] if object.respond_to?(:[])
  rescue KeyError
    nil
  end

  def require_account_admin
    redirect_to root_path, alert: t("must_be_an_admin") unless Current.account_admin?
  end
end
