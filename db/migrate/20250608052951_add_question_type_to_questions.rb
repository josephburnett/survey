class AddQuestionTypeToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :question_type, :string
    add_column :questions, :range_min, :float
    add_column :questions, :range_max, :float
  end
end
