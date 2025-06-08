class AddDeletedToAnswers < ActiveRecord::Migration[8.0]
  def change
    add_column :answers, :deleted, :boolean, default: false, null: false
  end
end
