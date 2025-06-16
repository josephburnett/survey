class UpdateMetricsForFunctionSystem < ActiveRecord::Migration[8.0]
  def change
    # Remove polymorphic source association
    remove_reference :metrics, :source, polymorphic: true, null: false
    
    # Rename aggregation to function and update allowed values
    rename_column :metrics, :aggregation, :function
    
    # Create join tables for many-to-many relationships
    create_table :metric_answers do |t|
      t.references :metric, null: false, foreign_key: true
      t.references :answer, null: false, foreign_key: true
      t.timestamps
    end
    
    create_table :metric_metrics do |t|
      t.references :parent_metric, null: false, foreign_key: { to_table: :metrics }
      t.references :child_metric, null: false, foreign_key: { to_table: :metrics }
      t.timestamps
    end
    
    # Add indexes for performance
    add_index :metric_answers, [:metric_id, :answer_id], unique: true
    add_index :metric_metrics, [:parent_metric_id, :child_metric_id], unique: true, name: 'index_metric_metrics_on_parent_and_child'
  end
end
