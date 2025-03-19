class CreateMassiveLoadInputs < ActiveRecord::Migration[8.0]
  def change
    create_table :massive_load_inputs do |t|
      t.integer :status
      t.integer :total_rows
      t.timestamps
    end
  end
end
