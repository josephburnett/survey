class AddScaleToMetrics < ActiveRecord::Migration[8.0]
  def change
    add_column :metrics, :scale, :decimal, precision: 10, scale: 4, default: 1.0
  end
end
