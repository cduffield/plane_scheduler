require "test_helper"

class UserProfileCertificatesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "profile page renders SkyRoute certificate form" do
    get edit_user_registration_path

    assert_response :success
    assert_select "h1", "My Profile"
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[avatar]']"
    assert_select ".sky-profile-danger-card button", text: "Delete my account"
    assert_select "h2", "Pilot Certificates & Ratings"
    assert_select "select[name='user[user_pilot_certificates_attributes][0][certificate_type]']"
    assert_select "select[name='user[user_pilot_certificates_attributes][0][category]']"
    assert_select "select[name='user[user_pilot_certificates_attributes][0][aircraft_class]']"
    assert_select "h2", "Medical Certificate"
    assert_select "select[name='user[user_medical_certificate_attributes][medical_class]']"
    assert_select "input[name='user[user_medical_certificate_attributes][certificate_number]']"
    assert_select "input[name='user[user_medical_certificate_attributes][issued_on]']"
    assert_select "input[name='user[user_medical_certificate_attributes][expires_on]']"
    assert_select "h2", "Total Hours"
    assert_select "input[name='user[total_time]']"
    assert_select "input[name='user[pic_time]']"
    assert_select "input[name='user[sic_time]']"
    assert_select "input[name='user[cross_country_time]']"
    assert_select "input[name='user[instrument_time]']"
    assert_select "input[name='user[night_time]']"
    assert_select "input[name='user[simulator_time]']"
    assert_select "input[name='user[dual_received_time]']"
    assert_select "input[name='user[solo_time]']"
  end

  test "user can add multiple pilot certificates" do
    put user_registration_path, params: {
      user: {
        name: @user.name,
        email: @user.email,
        user_pilot_certificates_attributes: {
          "0" => {
            certificate_type: "private_pilot",
            category: "airplane",
            aircraft_class: "single_engine_land",
            certificate_number: "1234567",
            issued_on: "2022-05-14"
          },
          "1" => {
            certificate_type: "instrument_rating",
            category: "airplane",
            aircraft_class: "single_engine_land",
            certificate_number: "7654321",
            issued_on: "2023-07-01"
          }
        }
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    assert_equal 2, @user.user_pilot_certificates.count
    assert_equal ["private_pilot", "instrument_rating"], @user.user_pilot_certificates.order(:created_at).pluck(:certificate_type)
  end

  test "user can save a pilot certificate from the rendered add rating fields" do
    put user_registration_path, params: {
      user: {
        name: @user.name,
        email: @user.email,
        user_pilot_certificates_attributes: {
          "0" => {
            certificate_type: "commercial_pilot",
            category: "airplane",
            aircraft_class: "multi_engine_land",
            certificate_number: "COMM-123",
            issued_on: "2024-03-20",
            _destroy: "0"
          }
        }
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    certificate = @user.user_pilot_certificates.order(:created_at).last
    assert_equal "commercial_pilot", certificate.certificate_type
    assert_equal "airplane", certificate.category
    assert_equal "multi_engine_land", certificate.aircraft_class
    assert_equal "COMM-123", certificate.certificate_number
  end

  test "blank add rating row does not block saving a filled dynamic row" do
    put user_registration_path, params: {
      user: {
        name: @user.name,
        email: @user.email,
        user_pilot_certificates_attributes: {
          "new_certificate_0" => {
            certificate_type: "",
            category: "",
            aircraft_class: "",
            certificate_number: "",
            issued_on: "",
            _destroy: "0"
          },
          "1717450000000" => {
            certificate_type: "cfi",
            category: "airplane",
            aircraft_class: "single_engine_land",
            certificate_number: "CFI-123",
            issued_on: "2025-01-10",
            _destroy: "0"
          }
        }
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    assert_equal ["cfi"], @user.user_pilot_certificates.pluck(:certificate_type)
  end

  test "user can save one medical certificate" do
    put user_registration_path, params: {
      user: {
        name: @user.name,
        email: @user.email,
        user_medical_certificate_attributes: {
          medical_class: "third_class",
          certificate_number: "MED-123",
          issued_on: "2026-01-15",
          expires_on: "2028-01-31"
        }
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    assert_equal "third_class", @user.user_medical_certificate.medical_class
    assert_equal "MED-123", @user.user_medical_certificate.certificate_number
    assert_equal Date.new(2026, 1, 15), @user.user_medical_certificate.issued_on
    assert_equal Date.new(2028, 1, 31), @user.user_medical_certificate.expires_on
  end

  test "user can save total flight hours" do
    put user_registration_path, params: {
      user: {
        name: @user.name,
        email: @user.email,
        total_time: "125.4",
        pic_time: "80.2",
        sic_time: "5.0",
        cross_country_time: "45.6",
        instrument_time: "12.3",
        night_time: "8.7",
        simulator_time: "3.5",
        dual_received_time: "32.1",
        solo_time: "18.9"
      }
    }

    assert_redirected_to edit_user_registration_path
    @user.reload
    assert_equal BigDecimal("125.4"), @user.total_time
    assert_equal BigDecimal("80.2"), @user.pic_time
    assert_equal BigDecimal("5.0"), @user.sic_time
    assert_equal BigDecimal("45.6"), @user.cross_country_time
    assert_equal BigDecimal("12.3"), @user.instrument_time
    assert_equal BigDecimal("8.7"), @user.night_time
    assert_equal BigDecimal("3.5"), @user.simulator_time
    assert_equal BigDecimal("32.1"), @user.dual_received_time
    assert_equal BigDecimal("18.9"), @user.solo_time
  end
end
