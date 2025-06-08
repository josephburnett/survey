class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :section, null: false, foreign_key: true

      t.timestamps
    end
  end
end
