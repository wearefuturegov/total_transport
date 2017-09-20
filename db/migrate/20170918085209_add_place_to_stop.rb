class AddPlaceToStop < ActiveRecord::Migration
  def change
    add_reference :stops, :place, index: true, foreign_key: true
    Stop.all.each do |s|
      s.place = Place.new(name: s.read_attribute(:name), latitude: s.read_attribute(:latitude), longitude: s.read_attribute(:longitude))
      s.save
    end
    remove_column :stops, :name, :string
    remove_column :stops, :latitude, :float
    remove_column :stops, :longitude, :float
  end
end
