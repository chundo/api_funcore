# Model User roles

class CreateUserRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_roles do |t|
      t.references :role, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :admin, null: true, foreign_key: false
      t.boolean :active
      t.boolean :is_expired
      t.string :expired_type
      t.string :expired_value

      t.timestamps
    end
  end
end
