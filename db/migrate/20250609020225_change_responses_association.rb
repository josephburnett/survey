class ChangeResponsesAssociation < ActiveRecord::Migration[8.0]
  def change
    remove_column :responses, :section_id, :integer
    add_column :responses, :form_id, :integer
  end
end
