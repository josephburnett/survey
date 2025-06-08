class CreateSections < ActiveRecord::Migration[8.0]
  def change
    create_table :sections do |t|
      t.string :name
      t.string :prompt

      t.timestamps
    end
  end
end
