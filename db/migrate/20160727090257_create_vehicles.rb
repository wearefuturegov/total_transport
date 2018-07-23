class CreateVehicles < ActiveRecord::Migration[4.2]
  def change
    create_table :vehicles do |t|
      t.references :team, index: true, foreign_key: true
      t.integer :seats
      t.string :registration
      t.string :make_model
      t.string :colour

      t.timestamps null: false
    end
  end
end
