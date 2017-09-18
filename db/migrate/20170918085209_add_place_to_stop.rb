class AddPlaceToStop < ActiveRecord::Migration
  def change
    add_reference :stops, :place, index: true, foreign_key: true
    Stop.all.each do |s|
      s.place = Place.new(name: s.name, latitude: s.latitude, longitude: s.longitude)
      s.save
    end
    remove_column :stops, :name
    remove_column :stops, :latitude
    remove_column :stops, :longitude
  end
end
