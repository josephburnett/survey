class ReplaceMetricAnswersWithMetricQuestions < ActiveRecord::Migration[8.0]
  def change
    # Drop the metric_answers table
    drop_table :metric_answers if table_exists?(:metric_answers)

    # Create metric_questions join table
    create_table :metric_questions do |t|
      t.references :metric, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.timestamps
    end

    # Add index for performance
    add_index :metric_questions, [ :metric_id, :question_id ], unique: true
  end
end
