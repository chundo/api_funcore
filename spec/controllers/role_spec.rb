require 'rails_helper'

RSpec.describe Api::V1::RolesController, type: :controller do
  describe 'responds to' do
    it 'responds to json by default' do
      post :create, params: { role: { name: 'user', code: 'USER', active: true, default: true } }
      expect(response.code).to eq '401'
    end

    it 'responds to custom formats when provided in the params' do
      get :index
      expect(response.code).to eq '401'
    end
  end
end
