class AddDeletedToMetrics < ActiveRecord::Migration[8.0]
  def change
    add_column :metrics, :deleted, :boolean, default: false, null: false
  end
end
