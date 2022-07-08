class CreateMagicLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :magic_links do |t|
      t.string :token
      t.datetime :expires_at
      t.references :user, null: false, foreign_key: true
      t.boolean :active

      t.timestamps
    end
  end
end
