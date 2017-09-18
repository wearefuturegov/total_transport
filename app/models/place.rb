class Place < ActiveRecord::Base
  has_many :stops
  
  def lat_lng
    Geokit::LatLng.new(self.latitude, self.longitude)
  end
end
