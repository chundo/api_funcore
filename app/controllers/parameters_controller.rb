class ParametersController < ApplicationController
  before_action :set_parameter, only: %i[show update destroy]

  # GET /parameters
  def index
    @parameters = Parameter.all

    render json: @parameters
  end

  # GET /parameters/1
  def show
    render json: @parameter
  end

  # POST /parameters
  def create
    @parameter = Parameter.new(parameter_params)

    if @parameter.save
      render json: @parameter, status: :created, location: @parameter
    else
      render json: @parameter.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /parameters/1
  def update
    if @parameter.update(parameter_params)
      render json: @parameter
    else
      render json: @parameter.errors, status: :unprocessable_entity
    end
  end

  # DELETE /parameters/1
  def destroy
    @parameter.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_parameter
    @parameter = Parameter.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def parameter_params
    params.require(:parameter).permit(:name, :code, :description, :user_id, :value, :my_model_id, :active, :is_public)
  end
end
