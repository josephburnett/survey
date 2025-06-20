class AddDashboardAssociations < ActiveRecord::Migration[8.0]
  def change
    # Join table for dashboard-question associations
    create_table :dashboard_questions do |t|
      t.references :dashboard, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :position, default: 0
      t.timestamps
    end
    
    # Join table for dashboard-form associations  
    create_table :dashboard_forms do |t|
      t.references :dashboard, null: false, foreign_key: true
      t.references :form, null: false, foreign_key: true
      t.integer :position, default: 0
      t.timestamps
    end
    
    # Join table for dashboard-dashboard associations (linking to other dashboards)
    create_table :dashboard_dashboards do |t|
      t.references :dashboard, null: false, foreign_key: true
      t.references :linked_dashboard, null: false, foreign_key: { to_table: :dashboards }
      t.integer :position, default: 0
      t.timestamps
    end
    
    # Add position to existing dashboard_metrics for ordering
    add_column :dashboard_metrics, :position, :integer, default: 0
    
    # Add unique constraints to prevent duplicates
    add_index :dashboard_questions, [:dashboard_id, :question_id], unique: true
    add_index :dashboard_forms, [:dashboard_id, :form_id], unique: true
    add_index :dashboard_dashboards, [:dashboard_id, :linked_dashboard_id], unique: true
  end
end
