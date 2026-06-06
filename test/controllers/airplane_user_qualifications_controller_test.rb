require "test_helper"

class AirplaneUserQualificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:company)
    @airplane = airplanes(:one)
    @airplane.update!(account: @account)
    @pilot = users(:two)
  end

  test "account admin can mark pilot checked out" do
    sign_in users(:one)
    switch_account @account

    assert_difference("AirplaneUserQualification.count") do
      post airplane_user_qualifications_path(@airplane), params: {
        airplane_user_qualification: {
          user_id: @pilot.id,
          checkout_completed_at: "2026-06-03",
          expires_on: "2027-06-03",
          notes: "Checkout complete"
        }
      }
    end

    assert_redirected_to airplane_path(@airplane)
    qualification = @airplane.airplane_user_qualifications.find_by!(user: @pilot)
    assert_equal users(:one), qualification.approved_by
    assert_equal Date.new(2026, 6, 3), qualification.checkout_completed_at
    assert_equal Date.new(2027, 6, 3), qualification.expires_on
    assert_equal "Checkout complete", qualification.notes
  end

  test "flight instructor can mark pilot checked out" do
    account_users(:company_regular_user).update!(flight_instructor: true)
    sign_in @pilot
    switch_account @account

    post airplane_user_qualifications_path(@airplane), params: {
      airplane_user_qualification: {
        user_id: users(:one).id,
        checkout_completed_at: "2026-06-03"
      }
    }

    assert_redirected_to airplane_path(@airplane)
    assert_equal @pilot, @airplane.airplane_user_qualifications.find_by!(user: users(:one)).approved_by
  end

  test "regular user cannot mark pilot checked out" do
    sign_in @pilot
    switch_account @account

    assert_no_difference("AirplaneUserQualification.count") do
      post airplane_user_qualifications_path(@airplane), params: {
        airplane_user_qualification: {
          user_id: users(:one).id,
          checkout_completed_at: "2026-06-03"
        }
      }
    end

    assert_redirected_to root_path
  end
end
