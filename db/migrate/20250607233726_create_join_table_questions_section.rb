class CreateJoinTableQuestionsSection < ActiveRecord::Migration[8.0]
  def change
    create_join_table :questions, :sections do |t|
      # t.index [:question_id, :section_id]
      # t.index [:section_id, :question_id]
    end
  end
end
