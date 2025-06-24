class CreateFormDrafts < ActiveRecord::Migration[8.0]
  def change
    create_table :form_drafts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :form, null: false, foreign_key: true
      t.json :draft_data

      t.timestamps
    end
    
    add_index :form_drafts, [:user_id, :form_id], unique: true
  end
end
