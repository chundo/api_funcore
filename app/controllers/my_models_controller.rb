class MyModelsController < ApplicationController
  before_action :set_my_model, only: %i[show update destroy]

  # GET /my_models
  def index
    @my_models = MyModel.all

    render json: @my_models
  end

  def migrate
    models = []
    ActiveRecord::Base.connection.tables.map do |model|
      models << { name: model.capitalize.singularize.camelize, code: model.upcase, value: model.downcase,
                  description: %(Model #{model.capitalize.singularize.camelize}), active: true }
      MyModel.create(models)
    end

    render json: models
  end

  # GET /my_models/1
  def show
    render json: @my_model
  end

  # POST /my_models
  def create
    @my_model = MyModel.new(my_model_params)

    if @my_model.save
      render json: @my_model, status: :created, location: @my_model
    else
      render json: @my_model.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /my_models/1
  def update
    if @my_model.update(my_model_params)
      render json: @my_model
    else
      render json: @my_model.errors, status: :unprocessable_entity
    end
  end

  # DELETE /my_models/1
  def destroy
    @my_model.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_my_model
    @my_model = MyModel.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def my_model_params
    params.require(:my_model).permit(:name, :code, :value, :description, :active)
  end
end
