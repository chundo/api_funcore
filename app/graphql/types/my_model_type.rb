# frozen_string_literal: true

module Types
  class MyModelType < Types::BaseObject
    field :id, ID, null: false
    field :name, String
    field :code, String
    field :value, String
    field :description, String
    field :active, Boolean
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
