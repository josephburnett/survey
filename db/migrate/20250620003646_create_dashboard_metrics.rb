class CreateDashboardMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :dashboard_metrics do |t|
      t.references :dashboard, null: false, foreign_key: true
      t.references :metric, null: false, foreign_key: true

      t.timestamps
    end
  end
end
