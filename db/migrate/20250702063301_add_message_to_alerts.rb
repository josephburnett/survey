class AddMessageToAlerts < ActiveRecord::Migration[8.0]
  def change
    add_column :alerts, :message, :text
  end
end
