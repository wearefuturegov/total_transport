class AddSlugToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :slug, :string
    add_index :places, :slug, unique: true
    Place.find_each(&:save)
  end
end
