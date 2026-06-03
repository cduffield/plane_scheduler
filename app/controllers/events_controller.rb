class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :destroy, :open_flight, :close_flight]
  before_action :set_operations_context, only: [:index, :new]

  # GET /events
  def index
    @pagy, @events = pagy(current_account.events.includes(:airplane).sort_by_params(params[:sort], sort_direction))
  end

  # GET /events/1 or /events/1.json
  def show
    @event_payment = @event.event_payments.find_by(user: current_user) if user_signed_in?
  end

  # GET /events/calendar.json
  def calendar
    events_scope = current_account.events.includes(:airplane)
    events_scope = events_scope.where(airplane_id: params[:airplane_id]) if params[:airplane_id].present?

    event_colors = ["#3b82f6", "#ef4444", "#10b981", "#f59e0b"]

    events = events_scope.map do |event|
      airplane_label = event.airplane&.n_number.presence || "##{event.airplane_id}"
      event_color = event_colors[event.airplane_id.to_i % event_colors.length]

      {
        id: event.id,
        title: airplane_label,
        start: calendar_time(event.start_time),
        end: calendar_time(event.end_time),
        backgroundColor: event_color,
        borderColor: event_color,
        textColor: "#ffffff",
        extendedProps: {
          blockColor: event_color
        },
        url: event_url(event)
      }
    end

    render json: events
  end

  # GET /events/new
  def new
    start_time = Time.current.change(hour: 8, min: 0, sec: 0)
    @event = Event.new(start_time:, end_time: start_time + 2.hours)
  end

  # GET /events/1/edit
  def edit
  end

  def open_flight
    if @event.scheduled? && @event.update(status: :open)
      redirect_to @event, notice: "Flight opened."
    else
      redirect_to @event, alert: "Flight could not be opened."
    end
  end

  def close_flight
    unless @event.open?
      redirect_to @event, alert: "Only open flights can be closed."
      return
    end

    @event.assign_attributes(close_flight_params.merge(status: :closed))

    Event.transaction do
      @event.save!
      @event.airplane.update!(
        hobbs_time: @event.hobbs_end,
        tach_time: @event.tach_end
      )
    end

    redirect_to @event, notice: "Flight closed."
  rescue ActiveRecord::RecordInvalid
    render :show, status: :unprocessable_content
  end

  # POST /events or /events.json
  def create
    event_attributes = event_params
    airplane = current_account.airplanes.find(event_attributes.delete(:airplane_id))
    @event = airplane.events.new(event_attributes)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @event.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    event_attributes = event_params
    @event.airplane = current_account.airplanes.find(event_attributes.delete(:airplane_id)) if event_attributes[:airplane_id].present?

    respond_to do |format|
      if @event.update(event_attributes)
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @event.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event.destroy!
    respond_to do |format|
      format.html { redirect_to events_path, status: :see_other, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = current_account.events.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path
  end

  def set_operations_context
    @airplanes = current_account.airplanes.order(:n_number)
    @upcoming_events = current_account.events.includes(:airplane)
      .where(start_time: Time.current.beginning_of_day..)
      .order(:start_time)
      .limit(3)
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.expect(event: [ :start_time, :end_time, :airplane_id, :tach_start, :tach_end, :hobbs_start, :hobbs_end, :status ]).to_h.symbolize_keys
  end

  def close_flight_params
    params.expect(event: [ :hobbs_end, :tach_end ])
  end

  def calendar_time(time)
    time&.strftime("%Y-%m-%dT%H:%M:%S")
  end
end
