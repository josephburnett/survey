class AddFirstMetricIdToMetrics < ActiveRecord::Migration[8.0]
  def change
    add_column :metrics, :first_metric_id, :integer
    add_foreign_key :metrics, :metrics, column: :first_metric_id
    add_index :metrics, :first_metric_id
  end
end
