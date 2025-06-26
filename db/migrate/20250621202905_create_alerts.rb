class CreateAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :alerts do |t|
      t.string :name, null: false
      t.references :metric, null: false, foreign_key: true
      t.decimal :threshold, precision: 10, scale: 2, null: false
      t.string :direction, null: false
      t.references :user, null: false, foreign_key: true
      t.string :namespace, default: ''
      t.boolean :deleted, default: false

      t.timestamps
    end

    add_index :alerts, :namespace
    add_index :alerts, [ :user_id, :deleted ]
  end
end
