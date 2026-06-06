require "test_helper"

class AirplanesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @airplane = airplanes(:one)
    sign_in users(:one)
  end

  test "should get index" do
    get airplanes_url
    assert_response :success
  end

  test "regular account member does not see new airplane links" do
    @airplane.update!(account: accounts(:company))
    sign_in users(:two)
    switch_account accounts(:company)

    get airplanes_url

    assert_response :success
    assert_select "a[href='#{new_airplane_path}']", count: 0
  end

  test "should get new" do
    get new_airplane_url
    assert_response :success
  end

  test "should create airplane" do
    assert_difference("Airplane.count") do
      post airplanes_url, params: {airplane: {n_number: @airplane.n_number}}
    end

    assert_redirected_to airplane_url(Airplane.last)
  end

  test "should create airplane and return to account admin" do
    assert_difference("Airplane.count") do
      post airplanes_url, params: {return_to: "account_admin", airplane: {n_number: "N12345", hobbs_time: 0, tach_time: 0, rate: 125.00}}
    end

    assert_redirected_to account_admin_url
  end

  test "should show airplane" do
    get airplane_url(@airplane)
    assert_response :success
  end

  test "admin can see pilot checkout form on airplane show" do
    get airplane_url(@airplane)

    assert_response :success
    assert_select "h2", "Pilot Checkouts"
    assert_select "form[action='#{airplane_user_qualifications_path(@airplane)}'][method='post']"
  end

  test "flight instructor can see pilot checkout form on airplane show" do
    @airplane.update!(account: accounts(:company))
    account_users(:company_regular_user).update!(flight_instructor: true)
    sign_in users(:two)
    switch_account accounts(:company)

    get airplane_url(@airplane)

    assert_response :success
    assert_select "h2", "Pilot Checkouts"
    assert_select "form[action='#{airplane_user_qualifications_path(@airplane)}'][method='post']"
  end

  test "regular user cannot see pilot checkout form on airplane show" do
    @airplane.update!(account: accounts(:company))
    sign_in users(:two)
    switch_account accounts(:company)

    get airplane_url(@airplane)

    assert_response :success
    assert_select "h2", text: "Pilot Checkouts", count: 0
    assert_select "form[action='#{airplane_user_qualifications_path(@airplane)}'][method='post']", count: 0
  end

  test "should get edit" do
    get edit_airplane_url(@airplane)
    assert_response :success
  end

  test "should update airplane" do
    patch airplane_url(@airplane), params: {airplane: {n_number: @airplane.n_number}}
    assert_redirected_to airplane_url(@airplane)
  end

  test "should update airplane solo requirements" do
    patch airplane_url(@airplane), params: {
      airplane: {
        n_number: @airplane.n_number,
        airplane_solo_requirement_attributes: {
          active: "1",
          requires_checkout: "1",
          required_certificate_type: "private_pilot",
          required_rating_type: "instrument_rating",
          recent_rental_days: "90"
        }
      }
    }

    assert_redirected_to airplane_url(@airplane)
    @airplane.reload
    assert @airplane.airplane_solo_requirement.active?
    assert @airplane.airplane_solo_requirement.requires_checkout?
    assert_equal "private_pilot", @airplane.airplane_solo_requirement.required_certificate_type
    assert_equal "instrument_rating", @airplane.airplane_solo_requirement.required_rating_type
    assert_equal 90, @airplane.airplane_solo_requirement.recent_rental_days
  end

  test "should destroy airplane" do
    assert_difference("Airplane.count", -1) do
      delete airplane_url(@airplane)
    end

    assert_redirected_to airplanes_url
  end
end
