class AirplanesController < ApplicationController
  before_action :set_airplane, only: [:show, :edit, :update, :destroy]
  before_action :require_admin_user, except: [:index, :show]

  # GET /airplanes
  def index
    @pagy, @airplanes = pagy(Airplane.sort_by_params(params[:sort], sort_direction))
  end

  # GET /airplanes/1 or /airplanes/1.json
  def show
  end

  # GET /airplanes/new
  def new
    @airplane = Airplane.new
  end

  # GET /airplanes/1/edit
  def edit
  end

  # POST /airplanes or /airplanes.json
  def create
    @airplane = Airplane.new(airplane_params)

    respond_to do |format|
      if @airplane.save
        format.html { redirect_to @airplane, notice: "Airplane was successfully created." }
        format.json { render :show, status: :created, location: @airplane }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @airplane.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /airplanes/1 or /airplanes/1.json
  def update
    respond_to do |format|
      if @airplane.update(airplane_params)
        format.html { redirect_to @airplane, notice: "Airplane was successfully updated." }
        format.json { render :show, status: :ok, location: @airplane }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @airplane.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /airplanes/1 or /airplanes/1.json
  def destroy
    @airplane.destroy!
    respond_to do |format|
      format.html { redirect_to airplanes_path, status: :see_other, notice: "Airplane was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_airplane
    @airplane = Airplane.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    redirect_to airplanes_path
  end

  # Only allow a list of trusted parameters through.
  def airplane_params
    params.expect(airplane: [ :n_number, :hobbs_time, :tach_time, :rate ])
  end

  def require_admin_user
    redirect_to root_path, alert: t("must_be_an_admin") unless current_user&.admin?
  end
end
