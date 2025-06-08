class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.references :user, null: false, foreign_key: true
      t.references :source, polymorphic: true, null: false
      t.string :resolution
      t.string :width
      t.string :aggregation

      t.timestamps
    end
  end
end
