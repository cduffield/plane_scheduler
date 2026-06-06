class AirplanesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_airplane, only: [:show, :edit, :update, :destroy]
  before_action :require_account_admin, except: [:index, :show]

  # GET /airplanes
  def index
    @pagy, @airplanes = pagy(current_account.airplanes.sort_by_params(params[:sort], sort_direction))
  end

  # GET /airplanes/1 or /airplanes/1.json
  def show
  end

  # GET /airplanes/new
  def new
    @airplane = current_account.airplanes.new
    @airplane.build_airplane_solo_requirement
  end

  # GET /airplanes/1/edit
  def edit
    @airplane.build_airplane_solo_requirement unless @airplane.airplane_solo_requirement
  end

  # POST /airplanes or /airplanes.json
  def create
    @airplane = current_account.airplanes.new(airplane_params)

    respond_to do |format|
      if @airplane.save
        format.html { redirect_to after_create_airplane_path, notice: "Airplane was successfully created." }
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
    @airplane = current_account.airplanes.find(params.expect(:id))
  rescue ActiveRecord::RecordNotFound
    redirect_to airplanes_path
  end

  # Only allow a list of trusted parameters through.
  def airplane_params
    params.expect(airplane: [
      :n_number,
      :hobbs_time,
      :tach_time,
      :rate,
      airplane_solo_requirement_attributes: [
        :id,
        :active,
        :requires_checkout,
        :required_certificate_type,
        :required_rating_type,
        :recent_rental_days
      ]
    ])
  end

  def require_account_admin
    redirect_to root_path, alert: t("must_be_an_admin") unless Current.account_admin?
  end

  def after_create_airplane_path
    return account_admin_path if params[:return_to] == "account_admin"

    @airplane
  end
end
