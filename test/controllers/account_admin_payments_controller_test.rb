require "test_helper"
require "ostruct"

class AccountAdminPaymentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:company)
    @admin = users(:one)
    sign_in @admin
    switch_account @account
  end

  test "account admin can view payment settings" do
    get account_admin_payments_path

    assert_response :success
    assert_select "h1", "Payment Settings"
    assert_select "form button", text: /Connect Stripe|Continue Stripe setup/
    assert_select "form[data-turbo='false']"
  end

  test "payment settings refreshes connected account status from stripe" do
    merchant = @account.set_merchant_processor(:stripe, processor_id: "acct_test_123", data: { onboarding_complete: false })
    stripe_account = OpenStruct.new(
      charges_enabled: true,
      payouts_enabled: true,
      details_submitted: true,
      requirements: OpenStruct.new(
        currently_due: [],
        eventually_due: [],
        past_due: [],
        disabled_reason: nil
      )
    )

    Stripe::Account.stub(:retrieve, stripe_account) do
      get account_admin_payments_path
    end

    assert_response :success
    assert merchant.reload.onboarding_complete?
    assert_select ".sky-badge", text: "Ready to accept payments"
    assert_select "dd", text: "Enabled"
  end

  test "payment settings shows stripe requirements when setup is incomplete" do
    @account.set_merchant_processor(:stripe, processor_id: "acct_test_456", data: { onboarding_complete: false })
    stripe_account = OpenStruct.new(
      charges_enabled: false,
      payouts_enabled: false,
      details_submitted: false,
      requirements: OpenStruct.new(
        currently_due: ["external_account", "individual.verification.document"],
        eventually_due: [],
        past_due: [],
        disabled_reason: "requirements.past_due"
      )
    )

    Stripe::Account.stub(:retrieve, stripe_account) do
      get account_admin_payments_path
    end

    assert_response :success
    assert_select ".sky-badge", text: "Setup incomplete"
    assert_select "li", text: "external account"
    assert_select "li", text: "individual verification document"
    assert_select "dd", text: "requirements.past_due"
  end

  test "non account admin cannot view payment settings" do
    sign_out @admin
    user = users(:two)
    sign_in user
    switch_account @account

    get account_admin_payments_path

    assert_redirected_to root_path
  end
end
