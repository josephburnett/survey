class CreateUserSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :backup_enabled, default: false
      t.string :backup_method
      t.string :backup_email
      t.text :encryption_key

      t.timestamps
    end

    add_index :user_settings, :user_id, unique: true
  end
end
