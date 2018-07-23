class CreatePassengers < ActiveRecord::Migration[4.2]
  def change
    create_table :passengers do |t|
      t.string :phone_number
      t.string :verification_code
      t.datetime :verification_code_generated_at
      t.boolean :verified

      t.timestamps null: false
    end
  end
end
