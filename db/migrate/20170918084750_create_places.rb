class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :slug

      t.timestamps null: false
    end
    
    add_index :places, :slug, unique: true
  end
end
