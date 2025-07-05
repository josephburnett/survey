class CreateMetricSeriesCache < ActiveRecord::Migration[8.0]
  def change
    create_table :metric_series_caches do |t|
      t.references :metric, null: false, foreign_key: true
      t.json :series_data
      t.datetime :calculated_at
      t.timestamps
    end

    add_index :metric_series_caches, :metric_id, unique: true unless index_exists?(:metric_series_caches, :metric_id)
    add_index :metric_series_caches, :calculated_at unless index_exists?(:metric_series_caches, :calculated_at)
  end
end