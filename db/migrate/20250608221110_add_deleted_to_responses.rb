class AddDeletedToResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :responses, :deleted, :boolean, default: false, null: false
  end
end
