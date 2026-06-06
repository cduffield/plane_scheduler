class SoloEligibilityCheck
  attr_reader :errors

  def initialize(user:, airplane:, start_time:)
    @user = user
    @airplane = airplane
    @start_time = start_time
    @errors = []
  end

  def eligible?
    errors.clear
    return true unless requirement&.active?

    check_user
    check_checkout if requirement.requires_checkout?
    check_certificate(requirement.required_certificate_type, "required certificate")
    check_certificate(requirement.required_rating_type, "required rating")
    check_recent_rental if requirement.recent_rental_days.present?

    errors.empty?
  end

  private

  attr_reader :user, :airplane, :start_time

  def requirement
    @requirement ||= airplane&.airplane_solo_requirement
  end

  def check_user
    errors << "logged-in pilot" if user.blank?
  end

  def check_checkout
    return if qualification&.checkout_current_on?(start_date)

    errors << "checkout flight"
  end

  def check_certificate(certificate_type, label)
    return if certificate_type.blank?
    return if user&.user_pilot_certificates&.exists?(certificate_type:)

    errors << label
  end

  def check_recent_rental
    return if recent_rental?

    errors << "rental in the last #{requirement.recent_rental_days} days"
  end

  def qualification
    @qualification ||= airplane.airplane_user_qualifications.find_by(user:)
  end

  def recent_rental?
    return false if user.blank? || start_time.blank?

    airplane.events
      .where(user:, status: Event.statuses[:closed], flight_instructor_id: nil)
      .where("start_time >= ? AND start_time < ?", start_time - requirement.recent_rental_days.days, start_time)
      .exists?
  end

  def start_date
    start_time&.to_date || Date.current
  end
end
