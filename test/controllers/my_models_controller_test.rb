require 'test_helper'

class MyModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @my_model = my_models(:one)
  end

  test 'should get index' do
    get my_models_url, as: :json
    assert_response :success
  end

  test 'should create my_model' do
    assert_difference('MyModel.count') do
      post my_models_url,
           params: { my_model: { active: @my_model.active, code: @my_model.code,
                                 description: @my_model.description, name: @my_model.name,
                                 value: @my_model.value } }, as: :json
    end

    assert_response :created
  end

  test 'should show my_model' do
    get my_model_url(@my_model), as: :json
    assert_response :success
  end

  test 'should update my_model' do
    patch my_model_url(@my_model),
          params: { my_model: { active: @my_model.active, code: @my_model.code,
                                description: @my_model.description, name: @my_model.name,
                                value: @my_model.value } }, as: :json
    assert_response :success
  end

  test 'should destroy my_model' do
    assert_difference('MyModel.count', -1) do
      delete my_model_url(@my_model), as: :json
    end

    assert_response :no_content
  end
end
