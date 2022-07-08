class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :my_model, null: false, foreign_key: true
      t.string :action
      t.string :method
      t.boolean :allow
      t.boolean :public
      t.references :user, null: false, foreign_key: true
      t.boolean :active
      t.boolean :is_expired
      t.string :expired_type
      t.string :expired_value

      t.timestamps
    end
  end
end
