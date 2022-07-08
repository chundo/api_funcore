class Api::V1::ParametersController < AppController
  before_action :set_parameter, only: %i[show update destroy]
  # before_action :doorkeeper_authorize!, except: %i[]
  # before_action :set_user, except: %i[]

  # code=code to find parameter
  # to_code=code for rename code
  # to_json=true for json true
  # */find?code=PAy2,PA1&to_json=true
  # */find?code=PAy2&to_json=true
  def find2
    isMany = params['code'].include?(',')
    if isMany
      codes = params['code'].split(',')
      @parameter = Parameter.where(code: codes, is_public: true, active: true)
      to_json = params['to_json'] == 'true'

      puts '----1'
      puts @parameter.to_json
      if @parameter
        render json: @parameter
      else
        render json: { error: 'Parameter not found' }, status: :not_found
      end
    else
      @parameter = Parameter.find_by(code: params['code'], is_public: true, active: true)
      to_json = params['to_json'] == 'true'

      if @parameter
        parameter = select(@parameter, to_json)
        if to_json && @parameter.value.include?('{' || '[')
          result = JSON.parse(@parameter.value)
          render json: result
        else
          @obj = {
            parameter: @parameter,
            parameters: parameter
          }
          render json: @obj
        end
      else
        render json: { error: 'Parameter not found' }, status: :not_found
      end
    end
  end

  def find
    isMany = params['code'].include?(',')
    response = nil
    if isMany
      codes = params['code'].split(',')
      @parameter = Parameter.where(code: codes, is_public: true, active: true)
      to_json = params['to_json'] == 'true'

      if @parameter && to_json
        parameter_response = []
        @parameter.each do |parameter|
          if parameter.value.include?('{' || '[')
            result = JSON.parse(parameter.value)
            parameter_response.push(result)
          else
            parameter_response.push(parameter.value)
          end
        end
        response = parameter_response
      elsif @parameter
        response = @parameter
      end
    else
      @parameter = Parameter.find_by(code: params['code'], is_public: true, active: true)
      to_json = params['to_json'] == 'true'

      if @parameter
        parameter = select(@parameter, to_json)
        if to_json && @parameter.value.include?('{' || '[')
          result = JSON.parse(@parameter.value)
          response = result
        else
          @obj = {
            parameter: @parameter,
            parameters: parameter
          }
          response = @obj
        end
      end
    end

    if response
      render json: response
    else
      render json: { error: 'Parameter not found' }, status: :not_found
    end
  end

  # GET /parameters
  def index
    @parameters = Parameter.page(params['page'] || 0).per(10)

    response = {
      data: @parameters,
      paginator: count(params['page'], 'Parameter', false),
      paginator1: count(params['page'], 'Parameter', true),
      paginator2: count_serach(params['page'], 'Parameter', @parameters)
    }

    render json: response
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

  def select(parameter, to_code)
    @result = []
    if parameter.value.include?('|')
      parameter.value.split('|').each do |parameter|
        obj = {
          name: parameter,
          code: to_code ? parameter.delete(' ') : parameter
        }
        @result << obj
      end
    else
      @parameter.value.split(',').each do |parameter|
        obj = {
          name: parameter,
          code: to_code ? parameter.delete(' ') : parameter
        }
        @result << obj
      end
    end

    @result
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_parameter
    @parameter = Parameter.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def parameter_params
    params.require(:parameter).permit(:name, :code, :description, :user_id, :value, :my_model_id, :active, :is_public)
  end
end
