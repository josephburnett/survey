class CreateAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :answers do |t|
      t.references :question, null: false, foreign_key: true
      t.string :answer_type
      t.string :string_value
      t.float :number_value
      t.boolean :bool_value
      t.float :range_min
      t.float :range_max

      t.timestamps
    end
  end
end
