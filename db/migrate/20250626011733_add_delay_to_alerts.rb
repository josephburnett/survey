class AddDelayToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :alerts, :delay, :integer, default: 1, null: false
  end
end
