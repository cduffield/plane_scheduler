class AccountAdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_account_admin

  def show
    @airplane = current_account.airplanes.new
    @account_users = current_account.account_users.includes(:user).order(created_at: :asc)
    @airplanes = current_account.airplanes.order(:n_number)
    @upcoming_events = current_account.events.includes(:airplane)
      .where(start_time: Time.current.beginning_of_day..)
      .order(:start_time)
      .limit(5)
    @maintenance_inspections = MaintenanceInspection.joins(:airplane)
      .where(airplanes: {account_id: current_account.id})
      .includes(:airplane)
      .order(:name)
  end

  private

  def require_account_admin
    redirect_to root_path, alert: t("must_be_an_admin") unless Current.account_admin?
  end
end
