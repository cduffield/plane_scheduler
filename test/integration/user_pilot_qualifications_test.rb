require "test_helper"

class UserPilotQualificationsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "user can update pilot qualifications" do
    put user_registration_path, params: {
      user: {
        name: @user.name,
        email: @user.email,
        pilot_certificates: ["student", "private_pilot", "instrument_rating"],
        aircraft_categories: ["airplane"],
        aircraft_classes: ["single_engine_land", "multi_engine_land"]
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    assert_equal ["student", "private_pilot", "instrument_rating"], @user.pilot_certificates
    assert_equal ["airplane"], @user.aircraft_categories
    assert_equal ["single_engine_land", "multi_engine_land"], @user.aircraft_classes
  end
end
