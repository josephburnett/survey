class CreateJoinTableFormsSection < ActiveRecord::Migration[8.0]
  def change
    create_join_table :forms, :sections do |t|
      # t.index [:form_id, :section_id]
      # t.index [:section_id, :form_id]
    end
  end
end
