class AddNameToMetrics < ActiveRecord::Migration[8.0]
  def change
    add_column :metrics, :name, :string
  end
end
