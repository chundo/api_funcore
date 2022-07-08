require 'test_helper'

class ParametersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parameter = parameters(:one)
  end

  test 'should get index' do
    get parameters_url, as: :json
    assert_response :success
  end

  test 'should create parameter' do
    assert_difference('Parameter.count') do
      post parameters_url,
           params: { parameter: { active: @parameter.active, code: @parameter.code, description: @parameter.description,
                                  is_public: @parameter.is_public, my_model_id: @parameter.my_model_id,
                                  name: @parameter.name, user_id: @parameter.user_id,
                                  value: @parameter.value } }, as: :json
    end

    assert_response :created
  end

  test 'should show parameter' do
    get parameter_url(@parameter), as: :json
    assert_response :success
  end

  test 'should update parameter' do
    patch parameter_url(@parameter),
          params: { parameter: { active: @parameter.active, code: @parameter.code, description: @parameter.description,
                                 is_public: @parameter.is_public, my_model_id: @parameter.my_model_id,
                                 name: @parameter.name, user_id: @parameter.user_id,
                                 value: @parameter.value } }, as: :json
    assert_response :success
  end

  test 'should destroy parameter' do
    assert_difference('Parameter.count', -1) do
      delete parameter_url(@parameter), as: :json
    end

    assert_response :no_content
  end
end
