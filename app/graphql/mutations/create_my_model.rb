class Mutations::CreateMyModel < Mutations::BaseMutation
  argument :name, String, required: true
  argument :code, String, required: true
  argument :value, String, required: true
  argument :description, String, required: true
  argument :active, Boolean, required: true

  field :my_model, Types::MyModelType, null: false
  field :errors, [String], null: false

  def resolve(name:, code:, value:, description:, active:)
    my_model = MyModel.new(description: description, name: name, value: value, code: code, active: active)
    if my_model.save
      {
        my_model: my_model,
        errors: []
      }
    else
      {
        my_model: nil,
        errors: my_model.errors.full_messages
      }
    end
  end
end
