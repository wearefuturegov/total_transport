class CreateLandmarks < ActiveRecord::Migration[4.2]
  def change
    create_table :landmarks do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.references :stop, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
