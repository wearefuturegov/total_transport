class CreateStops < ActiveRecord::Migration[4.2]
  def change
    create_table :stops do |t|
      t.string :name
      t.references :route, index: true, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.json :polygon
      t.integer :position
      t.integer :minutes_from_last_stop

      t.timestamps null: false
    end
  end
end
