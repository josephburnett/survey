class CreateAlertStatusCache < ActiveRecord::Migration[8.0]
  def change
    create_table :alert_status_caches do |t|
      t.references :alert, null: false, foreign_key: true
      t.boolean :is_activated, default: false
      t.decimal :current_value, precision: 10, scale: 2
      t.datetime :calculated_at
      t.timestamps
    end

    add_index :alert_status_caches, :alert_id, unique: true unless index_exists?(:alert_status_caches, :alert_id)
    add_index :alert_status_caches, :calculated_at unless index_exists?(:alert_status_caches, :calculated_at)
    add_index :alert_status_caches, :is_activated unless index_exists?(:alert_status_caches, :is_activated)
  end
end
