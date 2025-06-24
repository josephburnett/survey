class CreateReportAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :report_alerts do |t|
      t.references :report, null: false, foreign_key: true
      t.references :alert, null: false, foreign_key: true

      t.timestamps
    end
  end
end
