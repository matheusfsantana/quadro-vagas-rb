class CreateMassiveLoadReports < ActiveRecord::Migration[8.0]
  def change
    create_table :massive_load_reports do |t|
      t.references :massive_load_input, null: false, foreign_key: true
      t.integer :record_type
      t.integer :status
      t.integer :row_number
      t.string :description

      t.timestamps
    end
  end
end
