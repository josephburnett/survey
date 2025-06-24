class CreateReportMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :report_metrics do |t|
      t.references :report, null: false, foreign_key: true
      t.references :metric, null: false, foreign_key: true

      t.timestamps
    end
  end
end
