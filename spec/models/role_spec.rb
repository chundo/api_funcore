require 'rails_helper'

RSpec.describe Role, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  get_role = Role.new

  context 'Create Role' do # (almost) plain English
    it 'creando role' do #
      expect { Role.create! }.to raise_error(ActiveRecord::RecordInvalid)  # test code
    end

    it 'create role' do
      get_role
    end
  end
end
