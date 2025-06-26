class CreateDashboardAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :dashboard_alerts do |t|
      t.references :dashboard, null: false, foreign_key: true
      t.references :alert, null: false, foreign_key: true
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :dashboard_alerts, [ :dashboard_id, :position ]
  end
end
