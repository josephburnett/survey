class AddResponseIdToAnswers < ActiveRecord::Migration[8.0]
  def change
    add_reference :answers, :response, null: true, foreign_key: true
  end
end
