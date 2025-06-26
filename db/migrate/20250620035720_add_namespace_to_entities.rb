class AddNamespaceToEntities < ActiveRecord::Migration[8.0]
  def change
    add_column :forms, :namespace, :string, default: '', null: false
    add_column :sections, :namespace, :string, default: '', null: false
    add_column :questions, :namespace, :string, default: '', null: false
    add_column :answers, :namespace, :string, default: '', null: false
    add_column :responses, :namespace, :string, default: '', null: false
    add_column :metrics, :namespace, :string, default: '', null: false
    add_column :dashboards, :namespace, :string, default: '', null: false

    add_index :forms, :namespace
    add_index :sections, :namespace
    add_index :questions, :namespace
    add_index :answers, :namespace
    add_index :responses, :namespace
    add_index :metrics, :namespace
    add_index :dashboards, :namespace
  end
end
