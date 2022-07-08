module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
                               description: 'An example field added by the generator'
    def test_field
      'Hello World!'
    end

    field :all_models, [Types::MyModelType], null: false
    def all_models
      MyModel.all
    end

    field :all_active, [Types::MyModelType], null: false
    def all_active
      MyModel.where(active: true)
    end
  end
end
