class AddPlaceToStop < ActiveRecord::Migration
  def change
    add_reference :stops, :place, index: true, foreign_key: true
    Stop.all.each do |s|
      place = Place.find_or_create_by(name: s.read_attribute(:name))
      place.latitude = s.read_attribute(:latitude)
      place.longitude = s.read_attribute(:longitude)
      place.save
      s.place = place
      s.save
    end
    remove_column :stops, :name, :string
    remove_column :stops, :latitude, :float
    remove_column :stops, :longitude, :float
  end
end
