class MaintenanceInspectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_airplane
  before_action :set_maintenance_inspection, only: [:edit, :update, :destroy]
  before_action :set_latest_inspection_event, only: [:new, :create, :edit, :update]
  before_action :require_account_admin

  def new
    @maintenance_inspection = @airplane.maintenance_inspections.new(active: true)
  end

  def create
    @maintenance_inspection = @airplane.maintenance_inspections.new(maintenance_inspection_params)

    if save_inspection_with_latest_event
      redirect_to @airplane, notice: "Maintenance inspection was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    @maintenance_inspection.assign_attributes(maintenance_inspection_params)

    if save_inspection_with_latest_event
      redirect_to @airplane, notice: "Maintenance inspection was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @maintenance_inspection.destroy!
    redirect_to @airplane, status: :see_other, notice: "Maintenance inspection was successfully deleted."
  end

  private

  def set_airplane
    @airplane = current_account.airplanes.find(params.expect(:airplane_id))
  rescue ActiveRecord::RecordNotFound
    redirect_to airplanes_path
  end

  def set_maintenance_inspection
    @maintenance_inspection = @airplane.maintenance_inspections.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    redirect_to @airplane
  end

  def set_latest_inspection_event
    @latest_inspection_event =
      if defined?(@maintenance_inspection) && @maintenance_inspection.present?
        @maintenance_inspection.latest_event || MaintenanceInspectionEvent.new
      else
        MaintenanceInspectionEvent.new
      end
  end

  def maintenance_inspection_params
    maintenance_inspection_input
  end

  def latest_inspection_event_params
    params.fetch(:last_inspection_event, ActionController::Parameters.new).permit(:performed_at, :hobbs_time, :tach_time, :notes)
  end

  def maintenance_inspection_input
    params.expect(maintenance_inspection: [
      :name,
      :description,
      :tracking_type,
      :calendar_interval_value,
      :calendar_interval_unit,
      :hour_interval_type,
      :hour_interval_value,
      :active
    ])
  end

  def save_inspection_with_latest_event
    latest_event_params = latest_inspection_event_params

    MaintenanceInspection.transaction do
      @maintenance_inspection.save!

      sync_latest_inspection_event(latest_event_params)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    source = e.record

    if source.is_a?(MaintenanceInspectionEvent)
      source.errors.each do |error|
        @maintenance_inspection.errors.add(error.attribute, error.message)
      end
      @latest_inspection_event = source
    end

    false
  end

  def sync_latest_inspection_event(attributes)
    return if attributes.values.all?(&:blank?)

    event = @maintenance_inspection.latest_event || @maintenance_inspection.maintenance_inspection_events.build
    event.assign_attributes(attributes)
    event.save!
    @latest_inspection_event = event
  end

  def require_account_admin
    redirect_to root_path, alert: t("must_be_an_admin") unless Current.account_admin?
  end
end
