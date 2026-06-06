class AirplaneUserQualificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_airplane
  before_action :require_checkout_manager

  def create
    pilot = pilot_from_signed_token
    unless pilot && current_account.users.exists?(pilot.id)
      redirect_to @airplane, alert: "Select a valid pilot."
      return
    end

    qualification = @airplane.airplane_user_qualifications.find_or_initialize_by(user: pilot)
    qualification.assign_attributes(qualification_params.except(:user_id).merge(approved_by: current_user))

    if qualification.save
      redirect_to @airplane, notice: "Pilot checkout was saved."
    else
      redirect_to @airplane, alert: qualification.errors.full_messages.to_sentence
    end
  end

  private

  def set_airplane
    @airplane = current_account.airplanes.find(params.expect(:airplane_id))
  rescue ActiveRecord::RecordNotFound
    redirect_to airplanes_path
  end

  def require_checkout_manager
    return if Current.account_admin? || Current.account_user&.flight_instructor?

    redirect_to root_path, alert: t("must_be_an_admin")
  end

  def qualification_params
    params.expect(airplane_user_qualification: [
      :user_id,
      :checkout_completed_at,
      :expires_on,
      :notes
    ])
  end

  def pilot_from_signed_token
    User.find_signed(qualification_params[:user_id], purpose: :airplane_user_qualification)
  end
end
