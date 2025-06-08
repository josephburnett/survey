class AddUserIdToResponses < ActiveRecord::Migration[8.0]
  def change
    add_reference :responses, :user, null: true, foreign_key: true
  end
end
