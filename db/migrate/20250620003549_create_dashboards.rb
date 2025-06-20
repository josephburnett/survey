class CreateDashboards < ActiveRecord::Migration[8.0]
  def change
    create_table :dashboards do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
  end
end
