class CreateComparisonRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :comparison_runs do |t|
      t.string :repository_full_name, null: false
      t.string :from_version, null: false
      t.string :to_version, null: false
      t.boolean :github_authenticated, null: false, default: false

      t.timestamps
    end

    add_index :comparison_runs, :repository_full_name
    add_index :comparison_runs, :created_at
  end
end
