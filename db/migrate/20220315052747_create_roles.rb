class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.string :code
      t.text :description
      t.boolean :active
      t.boolean :default

      t.timestamps
    end
    add_index :roles, :code
  end
end
