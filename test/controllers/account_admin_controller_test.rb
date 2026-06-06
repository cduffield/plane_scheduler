require "test_helper"

class AccountAdminControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:company)
    @admin = users(:one)
    sign_in @admin
    switch_account @account
  end

  test "account admin page includes add aircraft modal" do
    get account_admin_path

    assert_response :success
    assert_select "button", text: "Add aircraft"
    assert_select "#add-aircraft-modal[aria-hidden='true']"
    assert_select "#add-aircraft-modal form[action='#{airplanes_path}'][method='post']"
    assert_select "#add-aircraft-modal input[name='return_to'][value='account_admin']", 1
    assert_select "#add-aircraft-title", text: "Add aircraft"
  end

  test "account admin page links to invite members and flight instructors" do
    get account_admin_path

    assert_response :success
    assert_select "a[href='#{new_account_account_invitation_path(@account)}']", text: "Invite user"
    assert_select "a[href='#{new_account_account_invitation_path(@account, role: "flight_instructor")}']", text: "Invite flight instructor"
  end
end
