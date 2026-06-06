require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user has many accounts" do
    user = users(:one)
    assert_includes user.accounts, accounts(:one)
    assert_includes user.accounts, accounts(:company)
  end

  test "user has a personal account" do
    user = users(:one)
    assert_equal accounts(:one), user.personal_account
  end

  test "can delete user with accounts" do
    assert_difference "User.count", -1 do
      users(:one).destroy
    end
  end

  test "renders name with ActionText to_plain_text" do
    user = users(:one)
    assert_equal user.name, user.attachable_plain_text_representation
  end

  test "can search users by name generated column" do
    assert_equal users(:one), User.search("one").first
  end

  test "normalizes pilot qualification arrays" do
    user = users(:one)
    user.update!(
      pilot_certificates: ["student", "", "cfi", "student"],
      aircraft_categories: ["airplane", "", "airplane"],
      aircraft_classes: ["single_engine_land", "", "multi_engine_land", "single_engine_land"]
    )

    assert_equal ["student", "cfi"], user.pilot_certificates
    assert_equal ["airplane"], user.aircraft_categories
    assert_equal ["single_engine_land", "multi_engine_land"], user.aircraft_classes
  end

  test "rejects unknown pilot qualifications" do
    user = users(:one)
    user.pilot_certificates = ["space shuttle"]
    user.aircraft_categories = ["airplane"]
    user.aircraft_classes = ["single_engine_land"]

    assert_not user.valid?
    assert_includes user.errors[:pilot_certificates], "contains an unknown option"
  end

  test "flight hour totals must be non-negative numbers" do
    user = users(:one)
    user.total_time = -1

    assert_not user.valid?
    assert_includes user.errors[:total_time], "must be greater than or equal to 0"
  end
end
