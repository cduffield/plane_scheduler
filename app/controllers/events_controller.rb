class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy, :open_flight, :close_flight]

  # GET /events
  def index
    @pagy, @events = pagy(Event.sort_by_params(params[:sort], sort_direction))
  end

  # GET /events/1 or /events/1.json
  def show
    @event_payment = @event.event_payments.find_by(user: current_user) if user_signed_in?
  end

  # GET /events/calendar.json
  def calendar
    events = Event.includes(:airplane).map do |event|
      airplane_label = event.airplane&.n_number.presence || "##{event.airplane_id}"
      {
        id: event.id,
        title: "Airplane #{airplane_label}",
        start: event.start_time&.iso8601,
        end: event.end_time&.iso8601,
        url: event_url(event)
      }
    end

    render json: events
  end

  # GET /events/new
  def new
    @event = Event.new
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
    @event = Event.new(event_params)

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
    respond_to do |format|
      if @event.update(event_params)
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
    @event = Event.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path
  end

  # Only allow a list of trusted parameters through.
  def event_params
    params.expect(event: [ :start_time, :end_time, :airplane_id, :tach_start, :tach_end, :hobbs_start, :hobbs_end, :status ])
  end

  def close_flight_params
    params.expect(event: [ :hobbs_end, :tach_end ])
  end
end
