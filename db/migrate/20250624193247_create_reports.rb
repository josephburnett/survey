class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.time :time_of_day
      t.string :interval_type
      t.json :interval_config
      t.datetime :last_sent_at
      t.boolean :deleted, default: false
      t.string :namespace

      t.timestamps
    end
  end
end
