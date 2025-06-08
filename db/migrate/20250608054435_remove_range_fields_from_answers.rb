class RemoveRangeFieldsFromAnswers < ActiveRecord::Migration[8.0]
  def change
    remove_column :answers, :range_min, :float
    remove_column :answers, :range_max, :float
  end
end
