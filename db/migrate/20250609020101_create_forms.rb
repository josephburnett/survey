class CreateForms < ActiveRecord::Migration[8.0]
  def change
    create_table :forms do |t|
      t.string :name
      t.integer :user_id
      t.boolean :deleted, default: false

      t.timestamps
    end
  end
end
