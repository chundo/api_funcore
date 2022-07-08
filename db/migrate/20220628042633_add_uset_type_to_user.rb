class AddUsetTypeToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_type, :string
    add_column :users, :verify_code, :string
  end
end
