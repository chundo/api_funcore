class AddUsernameToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :username, :string
    add_column :users, :referal_code, :string
    add_column :users, :phone, :string
    add_column :users, :uuid, :string
    add_column :users, :pin, :string
    add_column :users, :verified_account, :boolean
    add_column :users, :active, :boolean
    add_column :users, :terms, :boolean
  end
end
